USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_PPD_EOLCART2]    Script Date: 2023-03-22 오전 9:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2023-01-10,,>
-- Description:	<생산실적현황,일자별::불량율,>
--  불량율 = 불량수량/(양품수량+불량수량)*100 EOL
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_MES_PPD_EOLCART2] 
	   @WORKDATE_S			NVARCHAR(20)		-- 시작일
	  ,@WORKDATE_E          NVARCHAR(20)		-- 종료일
	  ,@WORK_ORDER          NVARCHAR(20)		-- 생산오더
	  ,@ITEMCODE            NVARCHAR(20)		-- 자재코드
AS
BEGIN
	SET NOCOUNT ON;
    SELECT
        CONVERT(CHAR(10), WR.WORKDATE, 23) AS WORKDATE -- 1.생산일자  
	  , Convert(numeric(13,2), Round((sum(WR.BAD_QTY)/ sum(WR.BAD_QTY +WR.IN_QTY))*100,3)) AS RATE   -- '11.불량율 = 불량수량/ 지시수량 * 100' ERROR_rate
    FROM  
      PP_WORK_ORDER  WO        -- 작업지시서 
	, PP_EOL_RESULT WR         -- 생산실적 (EOL)
	
WHERE 
        WO.WORK_ORDER_NO =WR.WORKORDERNO
	   AND ( isnull(@WORKDATE_S,'')=''OR (WR.WORKDATE >= @WORKDATE_S))
       AND ( isnull(@WORKDATE_E,'')=''OR (WR.WORKDATE <= @WORKDATE_E))
	   AND ( isnull(@WORK_ORDER,'')=''OR (WR.ERP_ORDER_NO = @WORK_ORDER))
	   AND ( isnull(@ITEMCODE,'')=''OR (WR.ITEMCODE = @ITEMCODE))
 GROUP BY  CONVERT(CHAR(10), WR.WORKDATE, 23)
 order by CONVERT(CHAR(10), WR.WORKDATE, 23)
END
