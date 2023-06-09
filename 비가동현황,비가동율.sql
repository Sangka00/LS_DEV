USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_NOP_CART1]    Script Date: 2023-03-22 오전 9:15:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 <Author,,CHO, Sang HO>
-- Create date: <2022-12-26,,>
-- Description:	<비가동현황,비가동율,>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_MES_NOP_CART1]
	   @WORKDATE_S			NVARCHAR(20)		-- 시작일
	  ,@WORKDATE_E          NVARCHAR(20)		-- 종료일
	  ,@WORK_ORDER          NVARCHAR(20)		-- 생산오더
	  ,@ITEMCODE            NVARCHAR(20)		-- 자재코드
	  ,@Layer               NVARCHAR(20)		-- 층수
	  ,@POPNO               NVARCHAR(20)		-- POPNO
AS
BEGIN

SET ANSI_WARNINGS OFF
	SET ARITHIGNORE ON
	SET ARITHABORT OFF

SELECT 
 POPNO,
 sum(RUN_MIN) as RUN_MIN,
 sum(STOPTIME_MIN) as STOPTIME_MIN,
 CASE WHEN sum(RUN_MIN) =0 THEN 0  ELSE
Convert(NUMERIC(6,2),  (sum( Convert(NUMERIC(6,2),STOPTIME_MIN))/sum( Convert(NUMERIC(6,2),RUN_MIN)))) *100 
 End  AS STOP_Rate ,
  
 Max(Layer) as Layer
 FROM
 (
	SELECT 
			(SELECT MA.PPC_NO    FROM [mesuser].MI_MACHINE     MA WhERE  MA.MACHINE_CODE=WR.MACHINE) AS POPNO   --3.POP 번호 POP_NO
		--  , DATEDIFF(MI, WR.[STARTDATE], WR.[ENDDATE] ) as RUN_MIN	--  가동시간(분)
		  , Convert(numeric(13,2),  Convert(numeric(13,2), workingtime)* 60 )AS RUN_MIN   --  가동시간(분)
		  , DATEDIFF(MI, DT.STARTDOWNTIME,  DT.ENDDOWNTIME) * 60 as STOPTIME_MIN	--  비가동시간(분)
		  , ( Select (select c_name from [mesuser].APP_LIBRARY_CODE 
			 where B_OID = MACHINE_LOCATION) as location
			  from [mesuser].MI_MACHINE
			  where MACHINE_CODE = WR.MACHINE 
			  ) AS Layer  -- 2. 라인위치
	  
	FROM
	  [mesuser].[PP_WORK_RESULT] WR 
	 , [mesuser].MM_DOWNTIME DT   
	WHERE
	WR.B_USE = 1
	AND WR.WORKNO = DT.WORKNO   -- 작업번호
	AND ( isnull(@WORKDATE_S,'')=''OR (WR.WORKDATE >= @WORKDATE_S))
    AND ( isnull(@WORKDATE_E,'')=''OR (WR.WORKDATE <= @WORKDATE_E))
	AND ( isnull(@WORK_ORDER,'')=''OR (WR.ERP_ORDER_NO = @WORK_ORDER))
	AND ( isnull(@ITEMCODE,'')=''OR (WR.ITEMCODE = @ITEMCODE))
	
) as TB
WHERE
  1=1
  AND ( isnull(@Layer,'')=''OR (Layer = @Layer))
  AND ( isnull(@POPNO,'')=''OR (POPNO = @POPNO))  
  AND  POPNO is not null
  GROUP by POPNO

END
