USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MON_R]    Script Date: 2023-03-22 오전 9:28:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2022-12-13,,>
-- Description:	<비가동현황_비가동이력,,>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_MON_R] 
	     @WORKDATE_S			NVARCHAR(20)		-- 시작일
		,@WORKDATE_E            NVARCHAR(20)		-- 종료일
	    ,@MACHINE               NVARCHAR(20)     --설비
		,@PROCESSCODE           NVARCHAR(20)   --공정
AS
BEGIN
	
	SET NOCOUNT ON;

   SELECT
        CONVERT(CHAR(10), WR.WORKDATE, 23) AS WORKDATE   -- 작업일자
	,   MI.MPROCESS_NAME  AS PROCESS
	, MM.MACHINE_NAME AS MACHINE_NAME
	, WR.WORKORDERNO  AS WORKORDERNO 
	, DT.STARTDOWNTIME AS STARTDOWNTIME 
	, DT.ENDDOWNTIME AS ENDDOWNTIME
	, DATEDIFF(MI, DT.STARTDOWNTIME,  DT.ENDDOWNTIME) as STOPTIME 
	FROM PP_WORK_RESULT WR, MM_DOWNTIME DT,  MI_MPROCESS MI,  MI_MACHINE MM 
	WHERE WR.WORKORDERNO = DT.WORKORDERNO
	AND WR.PROCESSCODE = MI.MPROCESS_CODE
	AND MM.MACHINE_CODE =WR.MACHINE
	AND ( isnull(@WORKDATE_S,'')=''OR (WR.WORKDATE >= @WORKDATE_S))
	AND ( isnull(@WORKDATE_E,'')=''OR (WR.WORKDATE <= @WORKDATE_E))
	AND ( isnull(@MACHINE,'')=''OR  (WR.MACHINE =@MACHINE))
	AND ( isnull(@PROCESSCODE,'')=''OR  (WR.PROCESSCODE =@PROCESSCODE))
END
