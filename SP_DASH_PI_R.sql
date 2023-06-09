USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_PI_R]    Script Date: 2023-03-22 오전 9:30:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <2022-12-12>
-- Description:	<지시대비 실적현황_생산정보>
-- =============================================
ALTER PROCEDURE[mesuser].[SP_DASH_PI_R] 
		 @WORKDATE_S			NVARCHAR(20)		-- 시작일
		,@WORKDATE_E            NVARCHAR(20)		-- 종료일
	    ,@ITEM_CODE                  NVARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT 
          WO.WORK_ORDER_NO  AS WORK_ORDER_NO    -- 작업지시번호
        , CONVERT(CHAR(10), WO.START_DATE, 23) AS START_DATE               -- 시작일		
		, APP2.C_NAME  AS ORDER_TYPE         --지시유형		
        , WO.ITEM_CODE   AS ITEM_CODE                     -- 품번 코드
		, MI.ITEM_NAME    AS ITEM_NAME                   --품명    
        , app.C_NAME  AS UNIT                  -- 단위		
		, Convert(numeric(13,1),ISNULL(WO.ORDER_QUANTITY,0)) AS  ORDER_QUANTITY      --지시수량
        , Convert(numeric(13,1),ISNULL(WO.WORK_QUANTITY,0)) AS  WORK_QUANTITY         -- 작업수량
      --  , ISNULL(WO.ACCEPTANCE_QUANTITY,0) AS  ACCEPTANCE_QUANTITY  -- 양품수량
      --  , ISNULL(WO.DEFECTIVE_QUANTITY,0) AS  DEFECTIVE_QUANTITY    --불량수량
		,Convert(numeric(13,1), Round( (ISNULL(WO.ACCEPTANCE_QUANTITY,0) + ISNULL(WO.DEFECTIVE_QUANTITY,0) ),1)) AS TOTal_SUM --생산수량
		, CASE WHEN ISNULL(WO.ORDER_QUANTITY,0) = 0  THEN 0 ELSE
		  Convert(NUMERIC(13,1), Round( ( (ISNULL(WO.ACCEPTANCE_QUANTITY,0) + ISNULL(WO.DEFECTIVE_QUANTITY,0) ) /  ISNULL(WO.ORDER_QUANTITY,0))*100,1)) 
		  END   SuCESS_P   --달성율
		FROM [PP_WORK_ORDER] WO, MI_ITEM MI
			,APP_LIBRARY_CODE APP    -- 품목유형
			,APP_LIBRARY_CODE APP2   
   WHERE 
       MI.ITEM_CODE = WO.ITEM_CODE
       AND  WO.B_USE=1
	   AND WO.UNIT =  APP.B_OID
	   AND WO.ORDER_TYPE =  APP2.B_OID
	   AND ( isnull(@WORKDATE_S,'')=''OR (WO.START_DATE >= @WORKDATE_S))
	   AND ( isnull(@WORKDATE_E,'')=''OR (WO.START_DATE <= @WORKDATE_E))
	   AND ( isnull(@ITEM_CODE,'')=''OR       (WO.ITEM_CODE =@ITEM_CODE))

END
