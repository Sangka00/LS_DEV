USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_NON_O_R]    Script Date: 2023-03-22 오전 9:29:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,CHO, Sang HO>
-- Create date: <2022-12-14>
-- Description:	<비가동현황_비가동율,KENDO GRID,> 
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_NON_O_R]  
	
	 @WORKDATE_S			NVARCHAR(20)		-- 시작일
	,@WORKDATE_E            NVARCHAR(20)		-- 종료일
	,@PROCESSCODE           NVARCHAR(20)        -- 공정  
	,@MACHINE               NVARCHAR(20)        -- 설비 
AS
BEGIN
	SET NOCOUNT ON;
  
  SELECT
	(CASE WHEN GROUPING(WR.MACHINE)= 1  THEN '합계'
	ELSE
	WR.MACHINE 
	 END) AS MACHINE 
	 , (CASE WHEN GROUPING(WR.MACHINE)= 1  THEN  NULL
	 ELSE
	  Max(MM.MACHINE_NAME)
	  END) AS MACHINE_NAME 
	  , count(WR.WORKNO) AS WORKNOSUM --작업수
	  , SUM( Convert(numeric,WR.WORKINGTIME))  AS  WORKINGTIMESUM -- //작업시간 합계
	  , SUM( DATEDIFF(MI, DT.STARTDOWNTIME,  DT.ENDDOWNTIME)) as STOPTIME
	   , MIN(WR.WORKINGTIME) AS MINWORKINGTIME -- MIN
	   , Max(WR.WORKINGTIME) as MaxWORKINGTIME  -- MAX
	   , Convert(numeric(13,1), Round(AVG(CONVERT(numeric,WR.WORKINGTIME)),1)) as MEANWORKINGTIME  -- Mean
	 FROM PP_WORK_RESULT WR ,  MI_MACHINE MM , MM_DOWNTIME DT
	 WHERE
	  MM.MACHINE_CODE =WR.MACHINE
	   AND  WR.WORKORDERNO = DT.WORKORDERNO
	   AND ( isnull(@WORKDATE_S,'')=''OR (WR.WORKDATE >= @WORKDATE_S))
	   AND ( isnull(@WORKDATE_E,'')=''OR (WR.WORKDATE <= @WORKDATE_E))
	   AND ( isnull(@MACHINE,'')=''OR  (WR.MACHINE =@MACHINE))
	   AND ( isnull(@PROCESSCODE,'')=''OR  (WR.PROCESSCODE =@PROCESSCODE))
	  GROUP BY  WR.MACHINE
	  With ROLLUP
END
