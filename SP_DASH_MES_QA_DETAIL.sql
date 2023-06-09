USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_QA_DETAIL]    Script Date: 2023-03-22 오전 9:28:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2023-02-15>
-- Description:	<불량현황,품질,상세검색>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_MES_QA_DETAIL] 
	@B_OID			NVARCHAR(50)		-- 시작일
AS
BEGIN
	SET ANSI_WARNINGS OFF
    SET ARITHIGNORE ON
    SET ARITHABORT OFF

SELECT 
          TEST_TYPE -- 0.검사유형 
	   ,  DEFECT_NAME  --1. 불량명
	   ,  DEFECT_QTY   --2. 불량수량
	   ,  B_OID        --3. 외래키값   
FROm(
	SELECT    '수입검사'    AS TEST_TYPE      -- 0.검사유형 
		   ,  DEFECT_NAME
		   ,  DEFECT_QTY 
		   ,  R_IQC_MASTER_OID AS B_OID
	FROM [mesuser].QM_IQC_DEFECT IQC_DEF 
	UNION
	SELECT   '공정(자주)검사'    AS TEST_TYPE      -- 0.검사유형 
		   ,  DEFECT_NAME
		   ,  DEFECT_QTY 
		   ,  R_LQC_MASTER_OID AS B_OID
	FROM [mesuser].QM_LQC_DEFECT LQC_DEF
	UNION
	SELECT   '초중종검사'    AS TEST_TYPE      -- 0.검사유형 
		   ,  DEFECT_NAME
		   ,  DEFECT_QTY 
		   ,  R_MQC_MASTER_OID AS B_OID
	FROM [mesuser].QM_MQC_DEFECT MQC_DEF
	UNION
	SELECT   '완제품검사'    AS TEST_TYPE      -- 0.검사유형 
		   ,  DEFECT_NAME
		   ,  DEFECT_QTY 
		   ,  R_FQC_MASTER_OID AS B_OID
	FROM [mesuser].QM_FQC_DEFECT FQC_DEF
	UNION
	SELECT   '출하검사'    AS TEST_TYPE      -- 0.검사유형 
		   ,  DEFECT_NAME
		   ,  DEFECT_QTY 
		   ,  R_OQC_MASTER_OID AS B_OID  
	FROM [mesuser].QM_OQC_DEFECT OQC_DEF
) TB
Where 1=1
AND B_OID=@B_OID
END
