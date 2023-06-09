USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_NOP_CART2]    Script Date: 2023-03-22 오전 9:15:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2022-12-22,,>
-- Description:	<비가동현황,비가동 사유,GRID & CART>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_MES_NOP_CART2] 
	   @WORKDATE_S			NVARCHAR(20)		-- 시작일
	  ,@WORKDATE_E          NVARCHAR(20)		-- 종료일
	  ,@PROCESS            NVARCHAR(20)		    -- 공정
	  ,@MACHINE            NVARCHAR(20)		    -- 설비코드
	  ,@LAYER               NVARCHAR(20)		-- 층수
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT  DOWNTIMEValue AS   Reason
       ,SUM_STOPTIME  AS  STOPTIME_MIN
	   , CASE WHEN ISNULL(SUM_STOPTIME,0) = 0 THEN 0
	     ELSE ROUND(CONVERT(float,SUM_STOPTIME)/ sum(SUM_STOPTIME) OVER(),2) * 100 END RATE
	   
	FROM
	(
	SELECT DOWNTIMEValue
		  ,sum(STOPTIME) AS SUM_STOPTIME
	FROM
	(
		SELECT
   
			  APP.C_NAME AS DOWNTIMEValue
			, DATEDIFF(MI, DT.STARTDOWNTIME,  DT.ENDDOWNTIME) AS STOPTIME
			, WR.MACHINE
			, ( Select (select c_name from APP_LIBRARY_CODE where B_OID = MACHINE_LOCATION) as location
			   from MI_MACHINE
			   where MACHINE_CODE = WR.MACHINE) AS Layer
		 FROM 
			  PP_WORK_ORDER  WO        -- 작업지시서 
			, PP_WORK_RESULT WR         -- 생산실적
			, MM_DOWNTIME    DT        -- 다운타임
			, APP_LIBRARY_CODE APP     -- 층확인
			, MI_MACHINE   MI
	
		WHERE 
			 WO.WORK_ORDER_NO =WR.WORKORDERNO
			AND DT.WORKORDERNO  =WR.WORKORDERNO
			AND APP.C_CODE =DT.DOWNTIMECODE -- 비가동 사유
			AND MI.MACHINE_CODE = WR.MACHINE

		   AND ( isnull(@WORKDATE_S,'')='' OR (WR.WORKDATE >= @WORKDATE_S))
           AND ( isnull(@WORKDATE_E,'')='' OR (WR.WORKDATE <= @WORKDATE_E))
	       AND ( isnull(@PROCESS,'')='' OR (WR.PROCESSCODE = @PROCESS))
	       AND ( isnull(@MACHINE,'')='' OR (WR.MACHINE = @MACHINE))
	
	) as TMP
	WHERE  1=1
	AND ( isnull(@LAYER,'')=''OR (Layer = @LAYER))
	--AND Layer ='4층'
	GROUP by DOWNTIMEValue
	) AS MM
END
