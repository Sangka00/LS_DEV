USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_NON_OPER_TIME]    Script Date: 2023-03-22 오전 9:29:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2023-03-17,,>
-- Description:	<품질관리_검사시간,,>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_NON_OPER_TIME]
	     @WORKDATE_S			NVARCHAR(20)		-- 시작일
		,@WORKDATE_E            NVARCHAR(20)		-- 종료일
		,@ITEM_CODE             NVARCHAR(20)   --자재코드
	    ,@ERP_ORDER_NO          NVARCHAR(20)     --ERP_ORDER_NO
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF
	SET ARITHIGNORE ON
	SET ARITHABORT OFF

   SELECT 
       TEST_DATE
	 , POP_NO
	 , Layer
	 , TEST_PROCESS_TYPE
	 , ERP_ORDER
	 , BATCH
	 , ITEM_CODE
	 , ITEM_NAME
	 , INSPECTION_QTY
	 , isnull(WORKING_TIME,0) AS WORKING_TIME
	 
	 ,isnull( (WORKING_TIME)/INSPECTION_QTY,0) AS ITEM_INS_TIME
	 , TEST_USER_NAME
FROM(
	SELECT     
	  (CONVERT(CHAR(10), OQC.TEST_DATE, 23)) AS TEST_DATE
	  
	  , OQC.POP_NO  AS POP_NO
	  , Max(Layers.C_NAME) AS Layer
	  , '출하검사'  AS TEST_PROCESS_TYPE -- 검사유형
	  , MAX(OQC.ERP_ORDER_NO) as ERP_ORDER
	  , MAX(QT.BATCH)   AS BATCH
	  , MAX(OQC.ITEM_CODE)         AS ITEM_CODE   --자재코드
	  , MAX(OQC.ITEM_NAME)         AS ITEM_NAME    --자재명
	  , SUM(OQC.INSPECTION_QTY)        AS INSPECTION_QTY -- 검사수량
	  , (SUM(Convert(numeric(13,3),OQC.INSP_WORKING_TIME)) *60)/60     AS WORKING_TIME  --검사시간(분)
	  
	  , MAX(TEST_USER_NAME)  AS TEST_USER_NAME
    FROM  [mesuser].[QM_OQC_MASTER] AS OQC   -- 출하검사
      , [mesuser].[MM_QC_DOWNTIME] AS QT --품질 비가동 
      , [dbo].[VW_Layers] AS Layers
   WHERE 1=1
      AND TRIM(OQC.POP_NO) = TRIM(QT.POPNO)
      AND Layers.POPNO = OQC.POP_NO
      AND OQC.TEST_DATE IS not null
	  
	  AND ( isnull(@WORKDATE_S,'')='' OR (CONVERT(CHAR(10), OQC.TEST_DATE, 23) >= @WORKDATE_S))
      AND ( isnull(@WORKDATE_E,'')='' OR (CONVERT(CHAR(10), OQC.TEST_DATE, 23) <= @WORKDATE_E))
      AND ( isnull(@ITEM_CODE,'')=''  OR  (ITEM_CODE =@ITEM_CODE))
      AND ( isnull(@ERP_ORDER_NO,'')='' OR  (ERP_ORDER_NO =@ERP_ORDER_NO))
   GROUP BY (CONVERT(CHAR(10), OQC.TEST_DATE, 23)), POP_NO,ITEM_CODE
   UNION
   SELECT     
	  (CONVERT(CHAR(10), FQC.TEST_DATE, 23)) AS TEST_DATE
	  
	  , FQC.POP_NO  AS POP_NO
	  , Max(Layers.C_NAME) AS Layer
	  , '최종검사'  AS TEST_PROCESS_TYPE -- 최종유형
	  , MAX(FQC.ERP_ORDER_NO) as ERP_ORDER
	  , MAX(QT.BATCH)   AS BATCH
	  , MAX(FQC.ITEM_CODE)         AS ITEM_CODE   --자재코드
	  , MAX(FQC.ITEM_NAME)         AS ITEM_NAME    --자재명
	  , SUM(FQC.INSPECTION_QTY)        AS INSPECTION_QTY -- 검사수량
	  , (SUM(Convert(numeric(13,3),FQC.INSP_WORKING_TIME)) *60)/60     AS WORKING_TIME  --검사시간(분)
	 
	  , MAX(TEST_USER_NAME)  AS TEST_USER_NAME
    FROM  [mesuser].[QM_FQC_MASTER] AS FQC   -- 출하검사
      , [mesuser].[MM_QC_DOWNTIME] AS QT --품질 비가동 
      , [dbo].[VW_Layers] AS Layers
   WHERE 1=1
      AND TRIM(FQC.POP_NO) = TRIM(QT.POPNO)
      AND Layers.POPNO = FQC.POP_NO
      AND FQC.TEST_DATE IS not null

	  AND ( isnull(@WORKDATE_S,'')='' OR (CONVERT(CHAR(10), FQC.TEST_DATE, 23) >= @WORKDATE_S))
      AND ( isnull(@WORKDATE_E,'')='' OR (CONVERT(CHAR(10), FQC.TEST_DATE, 23) <= @WORKDATE_E))
      AND ( isnull(@ITEM_CODE,'')=''  OR  (ITEM_CODE =@ITEM_CODE))
      AND ( isnull(@ERP_ORDER_NO,'')='' OR  (ERP_ORDER_NO =@ERP_ORDER_NO))

   GROUP BY (CONVERT(CHAR(10), FQC.TEST_DATE, 23)), POP_NO,ITEM_CODE

   UNION
   SELECT     
	  (CONVERT(CHAR(10), IQC.TEST_DATE, 23)) AS TEST_DATE
	  
	  , IQC.POP_NO  AS POP_NO
	  , Max(Layers.C_NAME) AS Layer
	  , '최종검사'  AS TEST_PROCESS_TYPE -- 검사유형
	  ,  '' as ERP_ORDER
	  , MAX(QT.BATCH)   AS BATCH
	  , MAX(IQC.ITEM_CODE)         AS ITEM_CODE   --자재코드
	  , MAX(IQC.ITEM_NAME)         AS ITEM_NAME    --자재명
	  , SUM(IQC.TEST_QTY)        AS INSPECTION_QTY -- 검사수량
	  , (SUM(Convert(numeric(13,3),IQC.INSP_WORKING_TIME)) *60)/60     AS WORKING_TIME  --검사시간(분)
	
	  , MAX(TEST_USER_NAME)  AS TEST_USER_NAME
    FROM  [mesuser].[QM_IQC_MASTER] AS IQC   -- 수입검사
      , [mesuser].[MM_QC_DOWNTIME] AS QT --품질 비가동 
      , [dbo].[VW_Layers] AS Layers
   WHERE 1=1
      AND TRIM(IQC.POP_NO) = TRIM(QT.POPNO)
      AND Layers.POPNO = IQC.POP_NO
      AND IQC.TEST_DATE IS not null

	  AND ( isnull(@WORKDATE_S,'')='' OR (CONVERT(CHAR(10), IQC.TEST_DATE, 23) >= @WORKDATE_S))
      AND ( isnull(@WORKDATE_E,'')='' OR (CONVERT(CHAR(10), IQC.TEST_DATE, 23) <= @WORKDATE_E))
      AND ( isnull(@ITEM_CODE,'')=''  OR  (ITEM_CODE =@ITEM_CODE))
     
   GROUP BY (CONVERT(CHAR(10), IQC.TEST_DATE, 23)), POP_NO,ITEM_CODE

) AS O
END
