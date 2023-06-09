USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_PPD_EOLCART3]    Script Date: 2023-03-22 오전 9:25:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date:<2023-02-10,,>
-- Description:	<생산실적현황,일자별::생산달성율, EOL>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_MES_PPD_EOLCART3] 
	   @WORKDATE_S			NVARCHAR(20)		-- 시작일
	  ,@WORKDATE_E          NVARCHAR(20)		-- 종료일
	  ,@WORK_ORDER          NVARCHAR(20)		-- 생산오더
	  ,@ITEMCODE            NVARCHAR(20)		-- 자재코드
AS
BEGIN
SELECT WORKDATE
 ,  ISNULL(  Convert(numeric(13,2), Round((sum(PRODUCTION_UPH)/sum(INSPECTION_UPH)) * 100 ,3)), 0)  AS RATE   --'생산 달성율'
FROM
(
SELECT
      CONVERT(CHAR(10), WR.WORKDATE, 23) AS WORKDATE -- 1.생산일자   
  , ( SELECT IT.PRODUCTION_UPH  FROM  MI_ITEM   IT  WhERE  IT.ITEM_CODE=WR.ITEMCODE ) AS  PRODUCTION_UPH
  ,  ( SELECT IT.INSPECTION_UPH  FROM  MI_ITEM   IT  WhERE  IT.ITEM_CODE=WR.ITEMCODE ) AS  INSPECTION_UPH  
 
 FROM  
      PP_WORK_ORDER  WO        -- 작업지시서 
	,  PP_EOL_RESULT WR         -- 생산실적	(EOL)
WHERE 
        WO.WORK_ORDER_NO =WR.WORKORDERNO
		AND ( isnull(@WORKDATE_S,'')=''OR (WR.WORKDATE >= @WORKDATE_S))
        AND ( isnull(@WORKDATE_E,'')=''OR (WR.WORKDATE <= @WORKDATE_E))
	   AND ( isnull(@WORK_ORDER,'')=''OR (WO.ERP_ORDER_NO = @WORK_ORDER))
	   AND ( isnull(@ITEMCODE,'')=''OR (WR.ITEMCODE = @ITEMCODE))	 
)  TB

GROUP by  WORKDATE
 order by WORKDATE
END
