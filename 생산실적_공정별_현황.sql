USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_PP_P_S]    Script Date: 2023-03-22 오전 9:17:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,CHO, Sang HO>
-- Create date: <2022-12-19>
-- Description:	<생산실적_공정별_현황,,>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_MES_PP_P_S]  
	 @WORKDATE_S			NVARCHAR(20)		-- 시작일
	,@WORKDATE_E            NVARCHAR(20)		-- 종료일
	,@PROCESSCODE           NVARCHAR(20)        -- 공정  
	,@ITEM                  NVARCHAR(20)        -- 품목 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT
MI.ITEM_CODE AS ITEMCODE,
 Max(MI.ITEM_NAME) AS ITEM_NAME,
  Max(app.C_NAME) AS C_NAME,
  -- P001 조립
  CASE WHEN MAX(PP.PROCESSCODE)='P001' THEN  ISNULL(SUM(PP.IN_QTY),0) ELSE 0 END AS IN_QTY,
  CASE WHEN MAX(PP.PROCESSCODE)='P001' THEN  ISNULL(SUM(PP.BAD_QTY),0) ELSE 0 END AS BAD_QTY,
  CASE WHEN MAX(PP.PROCESSCODE)='P001' THEN Round(convert(float,SUM(bad_qty))/ convert(float, SUM(PP.all_qty)),4)*100 ELSE 0 END AS bad_qty_P,
  --EOL검사
  CASE WHEN MAX(PP.PROCESSCODE)='P002' THEN  ISNULL(SUM(PP.IN_QTY),0) ELSE 0 END AS EOL_IN_QTY,
  CASE WHEN MAX(PP.PROCESSCODE)='P002' THEN  ISNULL(SUM(PP.BAD_QTY),0) ELSE 0 END AS EOL_BAD_QTY,
  CASE WHEN MAX(PP.PROCESSCODE)='P002' THEN Round(convert(float,SUM(bad_qty))/ convert(float, ISNULL(SUM(PP.all_qty),0)),6)*100 ELSE 0 END AS EOL_bad_qty_P,
  -- //조립
   CASE WHEN MAX(PP.PROCESSCODE)='P003' THEN  ISNULL(SUM(PP.IN_QTY),0) ELSE 0 END AS shipment_IN_QTY,
    CASE WHEN MAX(PP.PROCESSCODE)='P003' THEN  ISNULL(SUM(PP.BAD_QTY),0) ELSE 0 END AS shipment_BAD_QTY,
	CASE WHEN MAX(PP.PROCESSCODE)='P003' THEN Round(convert(float,SUM(bad_qty))/ convert(float, ISNULL(SUM(PP.all_qty),0)),6)*100 ELSE 0 END AS shipment_bad_qty_P,
	-- 출하 검사
 CASE  WHEN MAX(PP.PROCESSCODE)='P004' THEN ISNULL(SUM(IN_QTY),0) ELSE 0 END AS  assembly_IN_QTY,
  CASE WHEN MAX(PP.PROCESSCODE)='P004' THEN  ISNULL(SUM(PP.BAD_QTY),0) ELSE 0 END AS assembly_BAD_QTY,
  CASE WHEN MAX(PP.PROCESSCODE)='P004' THEN
      Round(convert(float,SUM(bad_qty))/ convert(float, ISNULL(SUM(PP.all_qty),0)),4)*100 ELSE 0 END AS assembly_bad_qty_P
 FROM PP_WORK_RESULT PP, MI_ITEM MI, APP_LIBRARY_CODE APP
 WHERE
 PP.ITEMCODE = MI.ITEM_CODE
 AND MI.ITEM_UNIT = APP.B_OID   
 
 AND ( isnull(@WORKDATE_S,'')=''OR (WORKDATE >= @WORKDATE_S))
 AND ( isnull(@WORKDATE_E,'')=''OR (WORKDATE <= @WORKDATE_E))
 AND ( isnull(@ITEM,'')=''OR  (ITEMCODE =@ITEM))
 AND ( isnull(@PROCESSCODE,'')=''OR  (PROCESSCODE =@PROCESSCODE))
 GROUP BY(MI.ITEM_CODE)
END
