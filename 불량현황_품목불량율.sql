USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_ID_R_CART]    Script Date: 2023-03-22 오전 9:11:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2022-12-14,,>
-- Description:	<불량현황_품목불량율 Cart,MES_ID_R>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_MES_ID_R_CART]
	     @WORKDATE_S			NVARCHAR(20)		-- 시작일
		,@WORKDATE_E            NVARCHAR(20)		-- 종료일
	    ,@MACHINE               NVARCHAR(20)     --설비
		,@PROCESSCODE           NVARCHAR(20)   --공정
AS
BEGIN

	SET NOCOUNT ON;

    SELECT  ITEM_NAME, SUM_BAD_QTY
    , ROUND(CONVERT(float,SUM_BAD_QTY)/ sum(SUM_BAD_QTY) OVER(),2) * 100 AS BAD_PER
	FROM(
		  SELECT
			  Max(MI.ITEM_NAME) AS ITEM_NAME  
			  , SUM(PP.BAD_QTY) AS SUM_BAD_QTY

			FROM PP_WORK_RESULT PP, MI_ITEM  MI 
			 WHERE     PP.ITEMCODE =   MI.ITEM_CODE
			  AND ( isnull(@WORKDATE_S,'')=''OR (PP.WORKDATE >= @WORKDATE_S))
              AND ( isnull(@WORKDATE_E,'')=''OR (PP.WORKDATE<= @WORKDATE_E))
	          AND ( isnull(@MACHINE,'')=''OR  (PP.MACHINE =@MACHINE))
	          AND ( isnull(@PROCESSCODE,'')=''OR  (PP.PROCESSCODE =@PROCESSCODE))
			 GROUP BY (PP.ITEMCODE)
	) AS MM
END
