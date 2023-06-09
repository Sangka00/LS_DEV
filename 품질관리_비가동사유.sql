USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_NON_OPER_CART]    Script Date: 2023-03-22 오전 9:14:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2023-03-17,,>
-- Description:	<품질관리_비가동사유,,>
-- =============================================
/*******************************************************************************************	
	■ 프로시저	: SP_DASH_MES_NON_OPER_CART
	■ 작성목적	: 품질관리 / 비가동현황(품질) / Tab3. 비가동사유
	■ 실행예제	: 
				  
				  EXEC [mesuser].[SP_DASH_MES_NON_OPER_CART] '','','','',''
	
	■ 비    고 : 
	 

	■ 주요변경내역    
	VER        DATE			AUTHOR				DESCRIPTION
	---------  ----------	---------------		------------------------------- 
	1.0        2023-03-17	CHO Sang HO         1. 신규생성 .
	1.1        2023-03-21	홍승진              1. 주석 추가.
*******************************************************************************************/
ALTER PROCEDURE [mesuser].[SP_DASH_MES_NON_OPER_CART] 
	     @WORKDATE_S			NVARCHAR(20)		-- 1.시작일
		,@WORKDATE_E            NVARCHAR(20)		-- 2.종료일
		,@POPNO                 NVARCHAR(20)        -- 3.POPNO
		,@Layer                 NVARCHAR(20)        -- 4.위치정보
	    ,@INSTYPE               NVARCHAR(20)        -- 5.검사유형
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT
        Reason																		-- 1.비동기 사유
	   , sum(INSP_WORKING_TIME)  AS SUM_INSP_WORKING_TIME							-- 2.비가동시간(분)
	   , sum(INSP_WORKING_TIME)*100 / sum(sum(INSP_WORKING_TIME)) OVER() AS Ratio	-- 3.비율
	   , Max(Layer) as Layer														-- 4.위치정보
	FROM
    (
	   SELECT
	     (SELECT APP.C_NAME  FROM APP_LIBRARY_CODE APP Where APP.C_CODE =DT.DOWNTIMECODE) AS Reason --'비가동 사유'
         ,  Convert(numeric(13,3), Convert(numeric(13,3),TIMESPAN*60) / 60) AS INSP_WORKING_TIME
		 , (select top 1 C_NAME from [dbo].[VW_Layers] Where popno = DT.POPNO ) AS Layer  -- 2.위치정보
        FROM   [QM_OQC_MASTER] QM,[MM_QC_DOWNTIME] DT
		WHERE QM.ITEM_CODE = DT.ITEMCODE
       AND QM.POP_NO =DT.POPNO
	   AND ( isnull(@WORKDATE_S,'')='' OR (QM.TEST_DATE >= @WORKDATE_S))
       AND ( isnull(@WORKDATE_E,'')='' OR (QM.TEST_DATE <= @WORKDATE_E))	  
	   AND ( isnull(@POPNO,'')='' OR (DT.POPNO = @POPNO)) 
	  

	   UNION
	   SELECT
	     (SELECT APP.C_NAME  FROM APP_LIBRARY_CODE APP Where APP.C_CODE =DT.DOWNTIMECODE) AS Reason --'비가동 사유'
         ,  Convert(numeric(13,3), Convert(numeric(13,3),TIMESPAN*60) / 60) AS INSP_WORKING_TIME
		 , (select top 1 C_NAME from [dbo].[VW_Layers] Where popno = DT.POPNO ) AS Layer  -- 2.위치정보
        FROM   [QM_FQC_MASTER] QM,[MM_QC_DOWNTIME] DT
		WHERE QM.ITEM_CODE = DT.ITEMCODE
       AND QM.POP_NO =DT.POPNO
	   AND ( isnull(@WORKDATE_S,'')='' OR (QM.TEST_DATE >= @WORKDATE_S))
       AND ( isnull(@WORKDATE_E,'')='' OR (QM.TEST_DATE <= @WORKDATE_E))	  
	   AND ( isnull(@POPNO,'')='' OR (DT.POPNO = @POPNO))
	   UNION
	   SELECT
	     (SELECT APP.C_NAME  FROM APP_LIBRARY_CODE APP Where APP.C_CODE =DT.DOWNTIMECODE) AS Reason --'비가동 사유'
         ,  Convert(numeric(13,3), Convert(numeric(13,3),TIMESPAN*60) / 60) AS INSP_WORKING_TIME
		 , (select top 1 C_NAME from [dbo].[VW_Layers] Where popno = DT.POPNO ) AS Layer  -- 2.위치정보
        FROM   [QM_IQC_MASTER] QM,[MM_QC_DOWNTIME] DT
		WHERE QM.ITEM_CODE = DT.ITEMCODE
       AND QM.POP_NO =DT.POPNO
	   AND ( isnull(@WORKDATE_S,'')='' OR (QM.TEST_DATE >= @WORKDATE_S))
       AND ( isnull(@WORKDATE_E,'')='' OR (QM.TEST_DATE <= @WORKDATE_E))	  
	   AND ( isnull(@POPNO,'')='' OR (DT.POPNO = @POPNO))
	   )AS O
WHERE 1=1
 AND ( isnull(@Layer,'')='' OR (Layer =@Layer)) 
 AND ( isnull(@INSTYPE,'')='' OR (Reason = @INSTYPE))
group by O.Reason
END
