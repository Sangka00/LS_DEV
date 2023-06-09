USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_ER_T_R]    Script Date: 2023-03-22 오전 9:11:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2022-12-15,,>
-- Description:	<불량현황_불량유형,,>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_MES_ER_T_R] 
	     @WORKDATE_S			NVARCHAR(20)		-- 시작일
		,@WORKDATE_E            NVARCHAR(20)		-- 종료일
	    ,@MACHINE               NVARCHAR(20)     --설비
		,@PROCESSCODE           NVARCHAR(20)   --공정
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT  DEFECT_NAME
      , BAD_QTY_SUM
	  , ROUND(CONVERT(float,BAD_QTY_SUM)/ sum(BAD_QTY_SUM) OVER(),4) * 100 AS BAD_QTY_RATE
    FROM
	(
	SELECT MI.DEFECT_NAME AS DEFECT_NAME
		, SUM(PP.BAD_QTY)     AS BAD_QTY_SUM 	
		FROM
		PP_WORK_RESULT PP,  PP_WORK_BAD BD,  MI_DEFECT_TYPE MI 
		WHERE PP.WORKORDERNO = BD.WORKORDERNO
		AND BD.DEFECT_CODE = MI.DEFECT_CODE
	    AND ( isnull(@WORKDATE_S,'')=''OR (BD.WORKDATE >= @WORKDATE_S))
		AND ( isnull(@WORKDATE_E,'')=''OR (BD.WORKDATE <= @WORKDATE_E))
		AND ( isnull(@MACHINE,'')=''OR  (BD.MACHINE =@MACHINE))
		AND ( isnull(@PROCESSCODE,'')=''OR  (BD.PROCESSCODE =@PROCESSCODE))
		GROUP BY MI.DEFECT_NAME
	
	) AS MM 

	
END
