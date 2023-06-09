USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_PP_D_S_R_CART]    Script Date: 2023-03-22 오전 9:16:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,CHO, Sang HO>
-- Create date: <2022-12-15>
-- Description:	<생산실적 일자별 현황,CART,>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_MES_PP_D_S_R_CART]  
	 @WORKDATE_S			NVARCHAR(20)		-- 시작일
	,@WORKDATE_E            NVARCHAR(20)		-- 종료일
	,@PROCESSCODE           NVARCHAR(20)        -- 공정  
	,@ITEM                  NVARCHAR(20)        -- 품목 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT CONVERT(CHAR(10), WR.WORKDATE, 23) AS WORKDATE
   , SUM(WR.IN_QTY) AS sum_IN_QTY  --양품수량
   , SUM(WR.BAD_QTY) AS sumBAD_QTY  -- 불량수량
  FROM[PP_WORK_RESULT] WR 
  LEFT OUTER JOIN MM_DOWNTIME as DT ON WR.WORKORDERNO = DT.WORKORDERNO
  , MI_ITEM MI, MI_MPROCESS MIM, MI_MACHINE MM, MI_ITEM IT
 WHERE MI.ITEM_CODE = WR.ITEMCODE
  AND MIM.MPROCESS_CODE = WR.PROCESSCODE 
  AND MM.MACHINE_CODE = WR.MACHINE
  AND IT.ITEM_CODE = WR.ITEMCODE
  AND ( isnull(@WORKDATE_S,'')=''OR (WR.WORKDATE >= @WORKDATE_S))
  AND ( isnull(@WORKDATE_E,'')=''OR (WR.WORKDATE <= @WORKDATE_E))
  AND ( isnull(@ITEM,'')=''OR  (WR.ITEMCODE =@ITEM))
  AND ( isnull(@PROCESSCODE,'')=''OR  (WR.PROCESSCODE =@PROCESSCODE))
 
GROUP BY WR.WORKDATE 
END
