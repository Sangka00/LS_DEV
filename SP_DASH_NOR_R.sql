USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_NOR_R]    Script Date: 2023-03-22 오전 9:30:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2022-12-14,,>
-- Description:	<비가동현황_비가동 사유,non-operation Reason,>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_NOR_R]   
	     @WORKDATE_S			NVARCHAR(20)		-- 시작일
		,@WORKDATE_E            NVARCHAR(20)		-- 종료일
	    ,@MACHINE               NVARCHAR(20)     --설비
		,@PROCESSCODE           NVARCHAR(20)   --공정
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT  DOWNTIMEValue
       ,SUM_STOPTIME
	   ,ROUND(CONVERT(float,SUM_STOPTIME)/ sum(SUM_STOPTIME) OVER(),2) * 100 AS STOPTIME_Rate
	FROM
	(
	SELECT MAX(APP.C_NAME) AS DOWNTIMEValue
			, SUM(DATEDIFF(MI, STARTDOWNTIME,  ENDDOWNTIME)) AS SUM_STOPTIME
	FROM MM_DOWNTIME , APP_LIBRARY_CODE APP
	WHERE APP.C_CODE =MM_DOWNTIME.DOWNTIMECODE
	AND ( isnull(@WORKDATE_S,'')=''OR (MM_DOWNTIME.CREATE_DATE >= @WORKDATE_S))
	AND ( isnull(@WORKDATE_E,'')=''OR (MM_DOWNTIME.CREATE_DATE <= @WORKDATE_E))
	AND ( isnull(@MACHINE,'')=''OR  (MM_DOWNTIME.MACHINE =@MACHINE))
	AND ( isnull(@PROCESSCODE,'')=''OR  (MM_DOWNTIME.PROCESSCODE =@PROCESSCODE))
	GROUP BY DOWNTIMECODE
	) AS MM 
END
