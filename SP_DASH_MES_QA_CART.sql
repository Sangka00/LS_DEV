USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_QA_CART]    Script Date: 2023-03-22 오전 9:27:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2023-01-19>
-- Description:	<품질 불량 이력 CART,,>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_MES_QA_CART] 
	   @TEST_DATE_S			NVARCHAR(20)		-- 시작일
	  ,@TEST_DATE_E          NVARCHAR(20)		-- 종료일
	  ,@POPNO				NVARCHAR(20)		-- POP번호
	  ,@ITEMCODE            NVARCHAR(20)         --자재코드
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
-- 1.수입검사
select    TRIM(DEFECT_NAME) AS  DEFECT_NAME    --1.불량유형
		 , sum(DEFECT_QUA)  AS DEFECT_SUM    --2. 불량수량	
		 , (select sum (DEFECT_QUA) as total_N 
		 FRom  [ExPle_DEV].[dbo].[VW_DASH_MES_QA_CART]
		 where 
		   1=1
	--	   AND ( isnull(@TEST_DATE_S,'')=''OR (TEST_DATE >= @TEST_DATE_S))
	--	   AND ( isnull(@TEST_DATE_E,'')=''OR (TEST_DATE <= @TEST_DATE_E))
	--	   AND ( isnull(@POPNO,'')=''OR (POP_NO = @POPNO))
	--	   AND ( isnull(@ITEMCODE,'')=''OR (ITEM_CODE = @ITEMCODE))
		 
		 
		 ) as Rate_TOTAL
FRom (
SELECT  [TEST_DATE]
       ,[POP_NO]
       ,[ITEM_CODE]
       ,[DEFECT_QUA]
       ,[DEFECT_NAME]
  FROM [ExPle_DEV].[dbo].[VW_DASH_MES_QA_CART]
  where 
   1=1
   AND ( isnull(@TEST_DATE_S,'')=''OR (TEST_DATE >= @TEST_DATE_S))
   AND ( isnull(@TEST_DATE_E,'')=''OR (TEST_DATE <= @TEST_DATE_E))
   AND ( isnull(@POPNO,'')=''OR (POP_NO = @POPNO))
   AND ( isnull(@ITEMCODE,'')=''OR (ITEM_CODE = @ITEMCODE))
) AS TB
group by DEFECT_NAME
END