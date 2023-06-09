USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_PI_R_SUB]    Script Date: 2023-03-22 오전 9:31:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,CHO, Sang HO>
-- Create date: <2022.12.13,,>
-- Description:	<지시대비 실적현황_생산정보,SUB 생산정보,>
-- =============================================
ALTER PROCEDURE [mesuser].[SP_DASH_PI_R_SUB] 
         @WORKDATE_S			NVARCHAR(20)		-- 시작일
		,@WORKDATE_E            NVARCHAR(20)		-- 종료일
	    ,@ITEM_CODE             NVARCHAR(20)     -- 품번
		,@WORKORDERNO           NVARCHAR(20)    -- 작업지시번호
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   select WR.WORKNO -- 작업번호
      , CONVERT(CHAR(10), WR.WORKDATE, 23) AS WORKDATE   -- 생산일자
	  , WR.ITEMCODE  --품번
	  , MI.ITEM_NAME    AS ITEM_NAME                   --품명    
	   ,  Convert(NUMERIC(13,1), Round(WR.IN_QTY,1)) AS IN_QTY   -- 양품수량
	    , Convert(NUMERIC(13,1), Round(WR.BAD_QTY,1)) AS BAD_QTY --불량수량
		from 
		 PP_WORK_RESULT WR,  MI_ITEM MI
		WHERE WR.B_USE=1
		AND MI.ITEM_CODE = WR.ITEMCODE
		AND ( isnull(@WORKDATE_S,'')=''OR (WR.WORKDATE >= @WORKDATE_S))
	    AND ( isnull(@WORKDATE_E,'')=''OR (WR.WORKDATE <= @WORKDATE_E))
	    AND ( isnull(@ITEM_CODE,'')=''OR  (WR.ITEMCODE =@ITEM_CODE))	
		AND ( isnull(@WORKORDERNO,'')=''OR  (WR.WORKORDERNO =@WORKORDERNO))	
		
END
