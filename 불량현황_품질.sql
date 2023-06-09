USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_ELG_DETAIL]    Script Date: 2023-03-22 오전 9:09:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2023-02-15>
-- Description:	<불량현황,품질,상세검색>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_MES_ELG_DETAIL] 
	@ERP_ORDER_NO		NVARCHAR(50)		-- 시작일
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF
    SET ARITHIGNORE ON
    SET ARITHABORT OFF

	SELECT 
      CASE WHEN PROCESSCODE = 'P001' THEN '생산' ELSE 
	         'EOL'   
	 END 	 TEST_TYPE -- 0.검사유형 
	,  ( SELECT MI.DEFECT_NAME FROM  [mesuser].MI_DEFECT_TYPE MI WHERE MI.DEFECT_CODE= BD.DEFECT_CODE) AS  DEFECT_NAME -- 1.불량명
	, BAD_QTY    --2.불량수량
	, ERP_ORDER_NO --3.ERP_ORDER_NO

	FROM [mesuser].[PP_WORK_BAD] BD
	where ERP_ORDER_NO = @ERP_ORDER_NO
END
