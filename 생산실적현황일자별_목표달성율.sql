USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_PPD_CART1]    Script Date: 2023-03-22 오전 9:18:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2022-12-22,,>
-- Description:	<생산실적현황,일자별::목표달성율,>
-- (양품수량 / 지시수량) *100
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_MES_PPD_CART1] 
       @WORKDATE_S			NVARCHAR(20)		-- 시작일
	  ,@WORKDATE_E          NVARCHAR(20)		-- 종료일
	  ,@WORK_ORDER          NVARCHAR(20)		-- 생산오더
	  ,@ITEMCODE            NVARCHAR(20)		-- 자재코드
AS
BEGIN
		
	SET NOCOUNT ON;
	SELECT
        CONVERT(CHAR(10), WR.WORKDATE, 23) AS WORKDATE -- 1.생산일자  
	  , Convert(numeric(13,2), Round((sum(WR.IN_QTY)/ sum(WO.ORDER_QUANTITY))*100,3)) AS RATE   -- '10.목표달성율 = 양품수량/지시수량 *100 ' SUCC_RATE target_attainment_rate
    FROM  
      PP_WORK_ORDER  WO        -- 작업지시서 
	, PP_WORK_RESULT WR         -- 생산실적
	
WHERE 
        WO.WORK_ORDER_NO =WR.WORKORDERNO
	   AND ( isnull(@WORKDATE_S,'')=''OR (WR.WORKDATE >= @WORKDATE_S))
       AND ( isnull(@WORKDATE_E,'')=''OR (WR.WORKDATE <= @WORKDATE_E))
	   AND ( isnull(@WORK_ORDER,'')=''OR (WO.ERP_ORDER_NO = @WORK_ORDER))
	   AND ( isnull(@ITEMCODE,'')=''OR (WR.ITEMCODE = @ITEMCODE))
 GROUP BY  WR.WORKDATE
 order by WR.WORKDATE

END
