USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_ER_H_R]    Script Date: 2023-03-22 오전 9:10:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2022-12-14,,>
-- Description:	<불량현황_불량이력,,>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_MES_ER_H_R] 
	     @WORKDATE_S			NVARCHAR(20)		-- 시작일
		,@WORKDATE_E            NVARCHAR(20)		-- 종료일
	   -- ,@MACHINE               NVARCHAR(20)     --설비
		,@PROCESSCODE           NVARCHAR(20)   --공정
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
-- 수입검사

SELECT
CONVERT(CHAR(10), MST.TEST_DATE, 23) AS WORKDATE  -- 검사일
 , '수입검사'   AS PROCESS 
 , MST.ITEM_CODE  -- 품번
 , MST.ITEM_NAME  -- 품(자재) 명
 ,(select c_name from app_library_code l where l.b_oid = b.item_type) AS ITEM_TYPE  --품목 유형
 , DEF.DEFECT_QTY  --불량수량
 , DEF.DEFECT_NAME --불량명
  , MST.B_ID    -- 검사 번호
  FROM QM_IQC_MASTER MST left outer join mi_item b on MST.r_item_oid = b.b_oid
  , QM_IQC_DEFECT DEF
  Where MST.B_OID = DEF.R_IQC_MASTER_OID 
  AND  MST.B_USE = 1  And   B_STATE = '4fd83b4eb829406481fe29849fc2d14e'  --Released
  AND ( isnull(@WORKDATE_S,'')=''OR (TEST_DATE >= @WORKDATE_S))
  AND ( isnull(@WORKDATE_E,'')=''OR (TEST_DATE <= @WORKDATE_E))
  AND ( isnull(@PROCESSCODE,'')=''OR  (MST.ITEM_CODE =@PROCESSCODE))
  --자주검사
  UNION
  SELECT
  CONVERT(CHAR(10), MST.TEST_DATE, 23) AS WORKDATE -- 검사일
  , '수입검사'   AS PROCESS --공정
  , MST.ITEM_CODE     -- 품번
  , MST.ITEM_NAME      -- 품(자재) 명
  ,(select c_name from app_library_code l where l.b_oid = b.item_type) AS ITEM_TYPE --품목 유형
  , DEF.DEFECT_QTY  --불량수량
  , DEF.DEFECT_NAME   --불량명
   , MST.B_ID       -- 검사 번호
    FROM QM_LQC_MASTER MST left outer join mi_item b on MST.r_item_oid = b.b_oid 
	 , QM_LQC_DEFECT DEF  
   Where MST.B_OID = DEF.R_LQC_MASTER_OID
    AND  MST.B_USE = 1  And   B_STATE = '4fd83b4eb829406481fe29849fc2d14e'  --Released
    AND ( isnull(@WORKDATE_S,'')=''OR (TEST_DATE >= @WORKDATE_S))
    AND ( isnull(@WORKDATE_E,'')=''OR (TEST_DATE <= @WORKDATE_E))
    AND ( isnull(@PROCESSCODE,'')=''OR  (MST.ITEM_CODE =@PROCESSCODE))
-- 초중종물검사
UNION
SELECT
CONVERT(CHAR(10), MST.TEST_DATE, 23) AS WORKDATE  -- 검사일
 , '초중종물검사'   AS PROCESS  --공정
 , MST.ITEM_CODE  -- 품번
  , MST.ITEM_NAME  -- 품(자재) 명
  ,(select c_name from app_library_code l where l.b_oid = b.item_type) AS ITEM_TYPE  --품목 유형
  , DEF.DEFECT_QTY  --불량수량
   , DEF.DEFECT_NAME --불량명
    , MST.B_ID  -- 검사 번호
	FROM QM_MQC_MASTER MST left outer join mi_item b on MST.r_item_oid = b.b_oid 
	 , QM_MQC_DEFECT DEF
	  Where MST.B_OID = DEF.R_MQC_MASTER_OID 
	  AND  MST.B_USE = 1  And   B_STATE = '4fd83b4eb829406481fe29849fc2d14e' 
	  AND ( isnull(@WORKDATE_S,'')=''OR (TEST_DATE >= @WORKDATE_S))
      AND ( isnull(@WORKDATE_E,'')=''OR (TEST_DATE <= @WORKDATE_E))
      AND ( isnull(@PROCESSCODE,'')=''OR  (MST.ITEM_CODE =@PROCESSCODE))
-- 최종검사
UNION
SELECT
CONVERT(CHAR(10), MST.TEST_DATE, 23) AS WORKDATE  -- 검사일
, '최종검사'   AS PROCESS   --공정
, MST.ITEM_CODE     -- 품번
, MST.ITEM_NAME    -- 품(자재) 명
, (select c_name from app_library_code l where l.b_oid = b.item_type) AS ITEM_TYPE --품목 유형
, DEF.DEFECT_QTY  --불량수량
, DEF.DEFECT_NAME  --불량명
, MST.B_ID    -- 검사 번호
FROM QM_FQC_MASTER MST left outer join mi_item b on MST.r_item_oid = b.b_oid
, QM_FQC_DEFECT DEF
Where MST.B_OID = DEF.R_FQC_MASTER_OID 
 AND  MST.B_USE = 1  And   B_STATE = '4fd83b4eb829406481fe29849fc2d14e'
 AND ( isnull(@WORKDATE_S,'')=''OR (TEST_DATE >= @WORKDATE_S))
 AND ( isnull(@WORKDATE_E,'')=''OR (TEST_DATE <= @WORKDATE_E))
 AND ( isnull(@PROCESSCODE,'')=''OR  (MST.ITEM_CODE =@PROCESSCODE))
 --출하검사
 UNION
  SELECT
   CONVERT(CHAR(10), MST.TEST_DATE, 23) AS WORKDATE  -- 검사일
   , '출하검사'   AS PROCESS --공정
   , MST.ITEM_CODE -- 품번
   , MST.ITEM_NAME  -- 품(자재) 명
   , (select c_name from app_library_code l where l.b_oid = b.item_type) AS ITEM_TYPE --품목 유형
   , DEF.DEFECT_QTY --불량수량
   , DEF.DEFECT_NAME --불량명
   , MST.B_ID   -- 검사 번호
   FROM QM_OQC_MASTER MST left outer join mi_item b on MST.r_item_oid = b.b_oid
    , QM_OQC_DEFECT DEF
	Where MST.B_OID = DEF.R_OQC_MASTER_OID
	AND  MST.B_USE = 1  And   B_STATE = '4fd83b4eb829406481fe29849fc2d14e'
	AND ( isnull(@WORKDATE_S,'')=''OR (TEST_DATE >= @WORKDATE_S))
    AND ( isnull(@WORKDATE_E,'')=''OR (TEST_DATE <= @WORKDATE_E))
    AND ( isnull(@PROCESSCODE,'')=''OR  (MST.ITEM_CODE =@PROCESSCODE))
 --POP
 -- 1. 작업일자 2. 공정 3.설비 4. 품번 5. 품명 6. 품목유형 7.불량수량 8.불량사유 9.작업지시번호
 UNION
 SELECT CONVERT(CHAR(10), PP.WORKDATE, 23) AS WORKDATE  --작업일자
 , MI.MPROCESS_NAME  AS PROCESS  -- 공정
 --, MM.MACHINE_NAME  --설비명
 , PP.ITEMCODE  AS ITEM_CODE    -- 품번
 , IT.ITEM_NAME  AS ITEM_NAME    -- 품(자재) 명
 , app.C_NAME    AS ITEM_TYPE     --품목 유형
 , BAD_QTY       AS DEFECT_QTY   --불량수량
 , DEF.DEFECT_NAME   AS DEFECT_NAME    --불량명(사유)
 , WORKORDERNO   AS B_ID -- 작업지시 번호
FROM    PP_WORK_BAD PP, MI_MPROCESS MI, MI_MACHINE MM, MI_ITEM IT ,  APP_LIBRARY_CODE APP , MI_DEFECT_TYPE DEF 
Where PP.PROCESSCODE = MI.MPROCESS_CODE 
    AND	PP.MACHINE =  MM.MACHINE_CODE
    AND  PP.ITEMCODE = IT.ITEM_CODE
    AND  IT.ITEM_UNIT = APP.B_OID
    AND  PP.DEFECT_CODE = DEF.DEFECT_CODE 
 	AND ( isnull(@WORKDATE_S,'')=''OR (WORKDATE >= @WORKDATE_S))
    AND ( isnull(@WORKDATE_E,'')=''OR (WORKDATE <= @WORKDATE_E))
    AND ( isnull(@PROCESSCODE,'')=''OR  ( PP.ITEMCODE =@PROCESSCODE))
  ORDER BY  WORKDATE, PROCESS 
END
