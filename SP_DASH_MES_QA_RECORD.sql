USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_QA_RECORD]    Script Date: 2023-03-22 오전 9:28:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Hong.Seoung.jin>
-- Create date: <2023-03-07>
-- Description:	<불량현황,품질,Tab1.자재불량이력>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_MES_QA_RECORD] 
	   @TEST_DATE_S			NVARCHAR(20)		-- 시작일
	  ,@TEST_DATE_E          NVARCHAR(20)		-- 종료일
	  ,@POPNO				NVARCHAR(20)		-- POP번호
	  ,@ITEMCODE            NVARCHAR(20)         --자재코드
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET ANSI_WARNINGS OFF
    SET ARITHIGNORE ON
    SET ARITHABORT OFF
SELECT 
           MAX(TEST_PROCESS_TYPE)                        AS TEST_PROCESS_TYPE       --   0.검사유형 
		 , MAX(CONVERT(CHAR(10), TEST_DATE, 23)) AS TEST_DATE       -- 1.검사일
		 , MAX(POP_NO)                           AS POP_NO		    -- 2. POP번호
		 , MAX(ERP_ORDER)                        AS ERP_ORDER	   --3. 생산오더
		 , MAX(ITEM_CODE)                        AS ITEM_CODE        --4. 자재코드
		 , MAX(ITEM_NAME)                        AS ITEM_NAME		 --5. 자재명
         , SUM(DEFECT_QUA)                       AS DEFECT_QUA      --6. 불량수량
		 , MAX(DEFECT_NAME)                      AS DEFECT_NAME      --7.불량유형
		 , MAX(DEFECT_Rate)                      AS DEFECT_Rate       --8. 불량율
		 , MAX(INSP_BATCH_NO)                    AS INSP_BATCH_NO     -- 9 배치번호		 
		 , MAX(Convert(numeric(13,2),
					   Round( QUALITY_QTY,3)))   AS  QUALITY_QTY      --10.검사수량
		,  MAX(FAIR_QUALITY_QTY)                 AS FAIR_QUALITY_QTY   --11.양품수량
		, B_OID
	FROM(
	  SELECT      '수입검사'             AS  TEST_PROCESS_TYPE
				  , TEST_DATE            AS  TEST_DATE     -- 1.검사일
				  , POP_NO               AS  POP_NO        -- 2. POP번호
				  , ''                   AS  ERP_ORDER      --3. 생산오더
				  , ITEM_CODE            AS  ITEM_CODE      --4. 자재코드
				  , ITEM_NAME            AS  ITEM_NAME      --5. 자재명
				,   DEFECT_QTY  AS  DEFECT_QUA    --6. 불량수량
			
				  , FAIR_QUALITY_QTY     AS FAIR_QUALITY_QTY --8.양품수량
				  ,  Convert(numeric(13,2),
						   Round( (DEFECT_QUALITY_QTY / 
								 ( DEFECT_QUALITY_QTY + FAIR_QUALITY_QTY) * 100),3)) as DEFECT_Rate
				  ,  INSP_BATCH_NO      AS INSP_BATCH_NO    --8. 배치번호
				  ,  DEFECT_QUALITY_QTY + FAIR_QUALITY_QTY      AS QUALITY_QTY --9.검사수량
				  , IQC.B_OID            AS  B_OID
				  , IQC_DEF.DEFECT_NAME AS  DEFECT_NAME  -- 10. 불량유형
			  FROM [mesuser].[QM_IQC_MASTER] IQC inner join QM_IQC_DEFECT IQC_DEF on IQC.B_OID = IQC_DEF.R_IQC_MASTER_OID
				 --, [mesuser].QM_IQC_DEFECT IQC_DEF
			  WHERE 1=1  
			  --IQC.B_OID = IQC_DEF.R_IQC_MASTER_OID   -- 수입검사
			  and  IQC.TEST_DATE is not null
			 and IQC.B_OID in (
			       Select R_IQC_MASTER_OID FRom [mesuser].QM_IQC_DEFECT 
				   )
	UNION
			  --  2. 공정(자주)검사
			  SELECT   '자주검사'                     AS     TEST_PROCESS_TYPE 
				  , TEST_DATE           AS  TEST_DATE    -- 1.검사일
				  ,  POP_NO              AS  POP_NO       -- 2. POP번호
				  ,  ERP_ORDER_NO       AS  ERP_ORDER    --3. 생산오더
				  ,  ITEM_CODE           AS  ITEM_CODE    --4. 자재코드
				  ,  ITEM_NAME           AS  ITEM_NAME    --5. 자재명
				  ,  DEFECT_QTY  AS  DEFECT_QUA    --6. 불량수량		

				   , FAIR_QUALITY_QTY     AS FAIR_QUALITY_QTY --8.양품수량
				  ,  Convert(numeric(13,2), 
							Round( (DEFECT_QUALITY_QTY / 
								   (DEFECT_QUALITY_QTY+FAIR_QUALITY_QTY) * 100),3)) AS DEFECT_Rate 
				  , ''                  AS  INSP_BATCH_NO   --8. 배치번호
				  ,  DEFECT_QUALITY_QTY + FAIR_QUALITY_QTY      AS QUALITY_QTY --9.검사수량
				  , LQC.B_OID            AS  B_OID
				  , LQC_DEF.DEFECT_NAME AS  DEFECT_NAME  -- 10. 불량유형
			  FRom [mesuser].QM_LQC_MASTER  LQC inner join QM_LQC_DEFECT LQC_DEF on LQC.B_OID = LQC_DEF.R_LQC_MASTER_OID
			  --, [mesuser].QM_LQC_DEFECT LQC_DEF   --공정(자주)검사
			  WHERE 1=1
			  -- LQC.B_OID = LQC_DEF.R_LQC_MASTER_OID   -- 고정(자주)검사
			  and  LQC.TEST_DATE is not null
			  and LQC.B_OID in (
			       Select R_LQC_MASTER_OID FRom [mesuser].QM_LQC_DEFECT 
				   )
	UNION
		  --3. 초중종검사
			SELECT  '초중종검사'                     AS     TEST_PROCESS_TYPE 
			  , TEST_DATE           AS  TEST_DATE    -- 1.검사일
			  ,  POP_NO              AS  POP_NO       -- 2. POP번호
			  ,  ERP_ORDER_NO       AS  ERP_ORDER    --3. 생산오더
			  ,  ITEM_CODE           AS  ITEM_CODE    --4. 자재코드
			  ,  ITEM_NAME           AS  ITEM_NAME    --5. 자재명
			  ,  DEFECT_QTY  AS  DEFECT_QUA    --6. 불량수량
			
			   , FAIR_QUALITY_QTY     AS FAIR_QUALITY_QTY --8.양품수량
			  ,  Convert(numeric(13,2), 
						Round( (DEFECT_QUALITY_QTY / 
							   (DEFECT_QUALITY_QTY+FAIR_QUALITY_QTY) * 100),3)) AS DEFECT_Rate 
			  , ''                  AS  INSP_BATCH_NO   --8. 배치번호
			   ,  DEFECT_QUALITY_QTY + FAIR_QUALITY_QTY      AS QUALITY_QTY --9.검사수량
			     , MQC.B_OID            AS  B_OID
				 , MQC_DEF.DEFECT_NAME AS  DEFECT_NAME  -- 10. 불량유형
		  FRom [mesuser].QM_MQC_MASTER  MQC inner join QM_MQC_DEFECT MQC_DEF on MQC.B_OID = MQC_DEF.R_MQC_MASTER_OID
		  --, [mesuser].QM_MQC_DEFECT MQC_DEF   --공정(자주)검사
		  WHERE 1=1
		  --MQC.B_OID = MQC_DEF.R_MQC_MASTER_OID   -- 초중종검사
		  and  MQC.TEST_DATE is not null
		  and MQC.B_OID in (
			       Select R_MQC_MASTER_OID FRom [mesuser].QM_MQC_DEFECT 
				   )
     UNION
		  --4. 완제품검사
			SELECT '최종검사'                     AS     TEST_PROCESS_TYPE  
			  , TEST_DATE           AS  TEST_DATE    -- 1.검사일
			  ,  POP_NO              AS  POP_NO       -- 2. POP번호
			  ,  ERP_ORDER_NO       AS  ERP_ORDER    --3. 생산오더
			  ,  ITEM_CODE           AS  ITEM_CODE    --4. 자재코드
			  ,  ITEM_NAME           AS  ITEM_NAME    --5. 자재명
			  ,  DEFECT_QTY  AS  DEFECT_QUA    --6. 불량수량
			
			   , FAIR_QUALITY_QTY     AS FAIR_QUALITY_QTY --8.양품수량
			  ,  Convert(numeric(13,2), 
						Round( (DEFECT_QUALITY_QTY / 
							   (DEFECT_QUALITY_QTY+FAIR_QUALITY_QTY) * 100),3)) AS DEFECT_Rate 
			  , INSP_BATCH_NO        AS INSP_BATCH_NO
			   ,  DEFECT_QUALITY_QTY + FAIR_QUALITY_QTY      AS QUALITY_QTY --9.검사수량
			     , FQC.B_OID            AS  B_OID
				 , FQC_DEF.DEFECT_NAME AS  DEFECT_NAME  -- 10. 불량유형
		  FRom [mesuser].QM_FQC_MASTER  FQC inner join QM_FQC_DEFECT FQC_DEF on FQC.B_OID = FQC_DEF.R_FQC_MASTER_OID
		   --, [mesuser].QM_FQC_DEFECT FQC_DEF   --공정(자주)검사
		  WHERE 1=1
		  --FQC.B_OID = FQC_DEF.R_FQC_MASTER_OID   -- 완제품검사
		  and  FQC.TEST_DATE is not null
		    and FQC.B_OID in (
			       Select R_FQC_MASTER_OID FRom [mesuser].QM_FQC_DEFECT 
				   )
		  UNION
		  -- 5. 출하검사
		   SELECT '출하검사'                     AS     TEST_PROCESS_TYPE  
		      , TEST_DATE           AS  TEST_DATE    -- 1.검사일
			  ,  POP_NO              AS  POP_NO       -- 2. POP번호
			  ,  ERP_ORDER_NO       AS  ERP_ORDER    --3. 생산오더
			  ,  ITEM_CODE           AS  ITEM_CODE    --4. 자재코드
			  ,  ITEM_NAME           AS  ITEM_NAME    --5. 자재명
			  ,  DEFECT_QTY  AS  DEFECT_QUA    --6. 불량수량
			
			   , FAIR_QUALITY_QTY     AS FAIR_QUALITY_QTY --8.양품수량
			  ,  Convert(numeric(13,2), 
						Round( (DEFECT_QUALITY_QTY / 
							   (DEFECT_QUALITY_QTY+FAIR_QUALITY_QTY) * 100),3)) AS DEFECT_Rate 
			   , INSP_BATCH_NO        AS INSP_BATCH_NO
			    ,  DEFECT_QUALITY_QTY + FAIR_QUALITY_QTY      AS QUALITY_QTY --9.검사수량
				 , OQC.B_OID            AS  B_OID
				 , OQC_DEF.DEFECT_NAME AS  DEFECT_NAME  -- 10. 불량유형
		  FRom [mesuser].QM_OQC_MASTER  OQC inner join QM_OQC_DEFECT OQC_DEF on OQC.B_OID = OQC_DEF.R_OQC_MASTER_OID
		  --, [mesuser].QM_OQC_DEFECT OQC_DEF   --공정(자주)검사
		  WHERE  1=1
		  --OQC.B_OID = OQC_DEF.R_OQC_MASTER_OID   -- 출하검사
		  and  OQC.TEST_DATE is not null
		    and OQC.B_OID in (
			       Select R_OQC_MASTER_OID FRom [mesuser].QM_OQC_DEFECT 
				   )

	 )AS TB
  Where 
  1=1

   AND ( isnull(@TEST_DATE_S,'')=''OR (convert(varchar(10), TEST_DATE, 120) >= @TEST_DATE_S))
   AND ( isnull(@TEST_DATE_E,'')=''OR (convert(varchar(10), TEST_DATE, 120) <= @TEST_DATE_E))
   AND ( isnull(@POPNO,'')=''OR (POP_NO = @POPNO))
   AND ( isnull(@ITEMCODE,'')=''OR (ITEM_CODE = @ITEMCODE))
  GROUP BY B_OID
  ORDER BY TEST_DATE  desc
END
