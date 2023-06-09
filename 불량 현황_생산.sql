USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_ELG]    Script Date: 2023-03-21 오후 5:28:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [mesuser].[SP_DASH_MES_ELG] 
	   @WORKDATE_S			NVARCHAR(20)		-- 시작일
	  ,@WORKDATE_E          NVARCHAR(20)		-- 종료일
	  ,@POPNO				NVARCHAR(20)		-- POP번호
	  ,@ITEMCODE            NVARCHAR(20)         --자재코드 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT
       MAX(TEST_PROCESS_TYPE) AS  TEST_PROCESS_TYPE 
     , MAX(WORKDATE) AS  WORKDATE   
	 , MAX(Layer) AS  Layer 
	 , MAX(POPNO) AS  POPNO 
	 , MAX(ITEM) AS  ITEM    
	 , MAX(ERP_ORDER_NO) AS  ERP_ORDER_NO
	 , MAX(ITEMCODE) AS  ITEMCODE  
	 , SUM(BAD_QTY) AS   BAD_QTY
	 , '' AS  DEFECT_NAME --개발 이후 삭제  
	 , AVG(Convert(numeric(13,2), 
	                   Round((BAD_QTY/ (QTY + BAD_QTY)) * 100,3))) as BAD_QTY_Rate -- 불량율	 
	 , SUM(Convert(numeric(13,2),
					   Round( QTY,3))) AS  QTY --10.검사수량
FROM
(
   SELECT
        '생산'            AS TEST_PROCESS_TYPE      -- 0.검사유형  
      , CONVERT(CHAR(10), WR.WORKDATE, 23) AS WORKDATE -- 1.생산일자
     , ( Select (select c_name from [mesuser].APP_LIBRARY_CODE where B_OID = MACHINE_LOCATION) as location
       from [mesuser].MI_MACHINE
       where MACHINE_CODE = WR.MACHINE) AS Layer  -- 2. 라인위치
	 , (SELECT MA.PPC_NO    FROM [mesuser].MI_MACHINE     MA WhERE  MA.MACHINE_CODE=WR.MACHINE) AS POPNO   --3.POP 번호 POP_NO
	 , WR.ERP_ORDER_NO AS ERP_ORDER_NO --생산오더
	 , WR.ITEMCODE    as ITEMCODE -- 자재코드 
	 , (SELECT  IT.ITEM_NAME  FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=WR.ITEMCODE)   AS   ITEM --6.자재명 ITEM
	 , WR.[BAD_QTY]     as BAD_QTY      -- 불량수량
	-- , BD.DEFECT_CODE  as DEFECT_CODE      -- 불량 테이블 불량 코드
	-- , ( SELECT MI.DEFECT_NAME FROM  MI_DEFECT_TYPE MI WHERE MI.DEFECT_CODE= BD.DEFECT_CODE) AS  DEFECT_NAME -- 불량유형
	 ,  Convert(numeric(13,2), Round((WR.[BAD_QTY]/ (WR.[IN_QTY]+ WR.[BAD_QTY])) * 100,3)) as BAD_QTY_Rate -- 불량율
	-- , ISNULL(BD.BAD_QTY,0)   as 불량수량    -- 불량수량
   --  , WR.[ALL_QTY]         -- 토탈수량
    --   , WR.[IN_QTY]          -- 양품수량
       , WR.[IN_QTY] + WR.BAD_QTY AS QTY
	   
 FROM [mesuser].[PP_WORK_RESULT] WR      
	 
 WHERE 
     WR.B_USE =1	
	 AND WR.PROCESSCODE='P001'

UNION
SELECT 
       'EOL'            AS TEST_PROCESS_TYPE      -- 0.검사유형 
     ,  CONVERT(CHAR(10), EOL.WORKDATE, 23) AS WORKDATE -- 1.생산일자
     , ( Select (select c_name from [mesuser].APP_LIBRARY_CODE where B_OID = MACHINE_LOCATION) as location
       from [mesuser].MI_MACHINE
       where MACHINE_CODE = EOL.MACHINE) AS Layer  -- 2. 라인위치
	 , (SELECT MA.PPC_NO    FROM [mesuser].MI_MACHINE     MA WhERE  MA.MACHINE_CODE=EOL.MACHINE) AS POPNO   --3.POP 번호 POP_NO
	 , EOL.ERP_ORDER_NO AS ERP_ORDER_NO --생산오더
	 , EOL.ITEMCODE    as ITEMCODE -- 자재코드 
	 , (SELECT  IT.ITEM_NAME  FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=EOL.ITEMCODE)   AS   ITEM --6.자재명 ITEM
	 , EOL.[BAD_QTY]     as BAD_QTY      -- 불량수량
	-- , BD.DEFECT_CODE  as DEFECT_CODE      -- 불량 테이블 불량 코드
	-- , ( SELECT MI.DEFECT_NAME FROM  MI_DEFECT_TYPE MI WHERE MI.DEFECT_CODE= BD.DEFECT_CODE) AS  DEFECT_NAME -- 불량유형
	 ,  Convert(numeric(13,2), Round((EOL.[BAD_QTY]/ (EOL.[IN_QTY]+ EOL.[BAD_QTY])) * 100,3)) as BAD_QTY_Rate -- 불량율
	-- , ISNULL(BD.BAD_QTY,0)   as 불량수량    -- 불량수량
   --  , WR.[ALL_QTY]         -- 토탈수량
    --   , WR.[IN_QTY]          -- 양품수량
       , EOL.[IN_QTY] + EOL.BAD_QTY AS QTY
	 
 FROM [mesuser].[PP_EOL_RESULT] EOL      
	 
 WHERE 
     EOL.PROCESSCODE='P002' 
	) AS TB
WHERE
	1=1
  AND BAD_QTY > 0	
  AND ( isnull(@WORKDATE_S,'')=''OR (WORKDATE >= @WORKDATE_S))
  AND ( isnull(@WORKDATE_E,'')=''OR (WORKDATE <= @WORKDATE_E))
  AND ( isnull(@POPNO,'')=''OR (POPNO = @POPNO))
  AND ( isnull(@ITEMCODE,'')=''OR (ITEMCODE = @ITEMCODE))
GROUP BY ERP_ORDER_NO
ORDER BY WORKDATE  desc
END
