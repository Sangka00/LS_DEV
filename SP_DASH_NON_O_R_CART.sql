USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_NON_O_R_CART]    Script Date: 2023-03-22 오전 9:29:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,CHO, Sang HO>
-- Create date: <2022-12-14>
-- Description:	<비가동현황_비가동율,KENDO CART>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_NON_O_R_CART]  
      @WORKDATE_S			NVARCHAR(20)		-- 시작일
	,@WORKDATE_E            NVARCHAR(20)		-- 종료일
	,@PROCESSCODE           NVARCHAR(20)        -- 공정  
	,@MACHINE               NVARCHAR(20)        -- 설비 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	/* 비가동현황_비가동률차트*/
SELECT
	   Max(MM.MACHINE_NAME) AS  MACHINE_NAME	  
	  , SUM( Convert(numeric,WR.WORKINGTIME))  AS  WORKINGTIMESUM -- //작업시간 합계
	  , SUM( DATEDIFF(MI, DT.STARTDOWNTIME,  DT.ENDDOWNTIME)) as STOPTIME
	 ,Convert(numeric(13,1), Round( SUM(  DATEDIFF(MI, DT.STARTDOWNTIME,  DT.ENDDOWNTIME)) / SUM( Convert(numeric,WR.WORKINGTIME)  )*100,1)) AS STOP_RATE
	FROM PP_WORK_RESULT WR ,  MI_MACHINE MM , MM_DOWNTIME DT
	 WHERE
	  MM.MACHINE_CODE =WR.MACHINE
	   AND  WR.WORKORDERNO = DT.WORKORDERNO
	   AND ( isnull(@WORKDATE_S,'')=''OR (WR.WORKDATE >= @WORKDATE_S))
	   AND ( isnull(@WORKDATE_E,'')=''OR (WR.WORKDATE <= @WORKDATE_E))
	   AND ( isnull(@MACHINE,'')=''OR  (WR.MACHINE =@MACHINE))
	   AND ( isnull(@PROCESSCODE,'')=''OR  (WR.PROCESSCODE =@PROCESSCODE))
	   	  GROUP BY  WR.MACHINE
END
