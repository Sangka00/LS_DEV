USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_PRO]    Script Date: 2023-03-22 오전 9:26:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************************	
	■ 프로시저	: SP_DASH_MES_PRO
	■ 작성목적	: 불량 현황(생산) Tab2.불량유형
	■ 실행예제	: 
				  
				  EXEC [mesuser].[SP_DASH_MES_PRO] '','','','',''
	
	■ 비    고 : 
	 

	■ 주요변경내역    
	VER        DATE			AUTHOR				DESCRIPTION
	---------  ----------	---------------		------------------------------- 
	1.0        2022-12-26	CHO Sang HO         1. 신규생성 .
	1.1        2023-03-15	홍승진              1. EOL_Result를 Union
                                                2. ERP_ORDER_NO 추가
*******************************************************************************************/
ALTER PROCEDURE [mesuser].[SP_DASH_MES_PRO]
	   @WORKDATE_S			NVARCHAR(20)		-- 시작일
	  ,@WORKDATE_E          NVARCHAR(20)		-- 종료일
	  ,@POPNO				NVARCHAR(20)		-- POP번호
	  ,@ITEMCODE            NVARCHAR(20)         --자재코드 
	  ,@Layer               NVARCHAR(20)         --층정보
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  SELECT   
         POPNO              AS POPNO             -- POP 번호
       , ITEMCODE           AS ITEMCODE          -- 자재코드
	   , ITEM               AS ITEM              -- 자재명
	   , IN_QTY             AS TOTAL_QTY         -- 지시수량
	   , IN_QTY             AS IN_QTY            -- 양품수량
	   , BAD_QTY            AS BAD_QTY           -- 불량수량
	   , Layer              AS Layer             -- 층
	   , BATCH              AS BATCH             -- BATCH
	   , ERP_ORDER_NO       AS ERP_ORDER_NO      -- ERP 번호
       , TEST_PROCESS_TYPE  AS TEST_PROCESS_TYPE -- 검사유형
       , DEFECT_NAME        AS DEFECT_NAME       -- 불량유형
	   , Convert(numeric(13,3), Round((BAD_QTY/ (BAD_QTY+IN_QTY)) * 100,4))  AS Rate -- 불량율  
	FROM(

	 SELECT   
		   CONVERT(CHAR(10), WR.WORKDATE, 23) AS WORKDATE -- 1.생산일자
		 , ( Select (select c_name from [mesuser].APP_LIBRARY_CODE where B_OID = MACHINE_LOCATION) as location
		   from [mesuser].MI_MACHINE
		   where MACHINE_CODE = WR.MACHINE) AS Layer  -- 2. 라인위치
		 , (SELECT MA.PPC_NO    FROM [mesuser].MI_MACHINE     MA WhERE  MA.MACHINE_CODE=WR.MACHINE) AS POPNO   --3.POP 번호 POP_NO
		 , WR.ERP_ORDER_NO AS ERP_ORDER_NO       -- 생산오더
		 , WR.ITEMCODE    as ITEMCODE            -- 자재코드 
		 , (SELECT  IT.ITEM_NAME  FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=WR.ITEMCODE)   AS   ITEM --6.자재명 ITEM
		 , WR.[BAD_QTY]     as BAD_QTY           -- 불량수량
		-- , BD.DEFECT_CODE  as DEFECT_CODE      -- 불량 테이블 불량 코드
		 ,( SELECT MI.DEFECT_NAME FROM  MI_DEFECT_TYPE MI WHERE MI.DEFECT_CODE= BD.DEFECT_CODE) AS  DEFECT_NAME -- 불량유형
		 ,  Convert(numeric(13,3), Round((WR.[BAD_QTY]/ (WR.[IN_QTY]+ WR.[BAD_QTY])) * 100,4)) as BAD_QTY_Rate  -- 불량율
	--	 , ISNULL(BD.BAD_QTY,0)   as BAD_QTY    -- 불량수량
	   --  , WR.[ALL_QTY]                       -- 토탈수량
		   , WR.[IN_QTY]    as   IN_QTY         -- 양품수량
		   ,BD.BATCH        as  BATCH
		    ,CASE WHEN BD.PROCESSCODE = 'P001' THEN '생산' ELSE 
	         'EOL'   
	 END 	 TEST_PROCESS_TYPE -- 0.검사유형 
	 FROM [mesuser].[PP_WORK_RESULT] WR LEFT JOIN 
		  [mesuser].[PP_WORK_BAD] BD ON WR.ERP_ORDER_NO = BD.ERP_ORDER_NO
	 WHERE 
		 WR.B_USE =1
		 AND WR.B_USE =1
		 AND BD.BAD_QTY >0
		 AND ( isnull(@WORKDATE_S,'')=''OR (WR.WORKDATE >= @WORKDATE_S))
         AND ( isnull(@WORKDATE_E,'')=''OR (WR.WORKDATE <= @WORKDATE_E))

	UNION
	SELECT 
		CONVERT(CHAR(10), EOL.WORKDATE, 23)	 AS WORKDATE --  생산일자
		,( Select (
				select c_name 
				from [mesuser].APP_LIBRARY_CODE 
				where B_OID = MACHINE_LOCATION) AS location
		   from [mesuser].MI_MACHINE
		   where MACHINE_CODE = EOL.MACHINE)	AS Layer --  라인위치
		,(SELECT MA.PPC_NO    FROM [mesuser].MI_MACHINE     MA WHERE  MA.MACHINE_CODE=EOL.MACHINE)	AS  POPNO --  POP 번호 POP_NO
		,EOL.ERP_ORDER_NO  AS ERP_ORDER_NO  --  생산오더
		,EOL.ITEMCODE	   AS ITEMCODE  --  자재코드
		,(SELECT  IT.ITEM_NAME  FROM  [mesuser].MI_ITEM   IT  WhERE  IT.ITEM_CODE=EOL.ITEMCODE)  AS ITEM  --  자재명 ITEM
		,EOL.BAD_QTY	   AS BAD_QTY  -- 7. 불량수량
		,( SELECT MI.DEFECT_NAME FROM  MI_DEFECT_TYPE MI WHERE MI.DEFECT_CODE= BD.DEFECT_CODE) 	AS  DEFECT_NAME --  불량유형
		,Convert(numeric(13,3), Round((EOL.[BAD_QTY]/ (EOL.[IN_QTY]+ EOL.[BAD_QTY])) * 100,4))	AS  BAD_QTY_Rate --  불량율
		,EOL.IN_QTY	AS IN_QTY  -- 양품수량
	    ,BD.BATCH as BATCH   --  배치
		,CASE WHEN EOL.PROCESSCODE = 'P002' THEN 'EOL' ELSE '' END  TEST_PROCESS_TYPE -- 검사유형
	FROM 
		[mesuser].[PP_EOL_RESULT] EOL LEFT JOIN
		[mesuser].[PP_WORK_BAD] BD ON EOL.ERP_ORDER_NO = BD.ERP_ORDER_NO		
	WHERE 
		EOL.BAD_QTY > 0
		AND ( isnull(@WORKDATE_S,'')=''OR (EOL.WORKDATE >= @WORKDATE_S))
        AND ( isnull(@WORKDATE_E,'')=''OR (EOL.WORKDATE <= @WORKDATE_E))

		 
	) as TB
	WHERE
	 1=1	 
	 AND BAD_QTY > 0	
	 AND ( isnull(@Layer,'')=''OR  ( Layer = @Layer))
	 AND ( isnull(@ITEMCODE,'')=''OR  ( ITEMCODE =@ITEMCODE))
	 AND ( isnull(@POPNO,'')=''OR  ( POPNO =@POPNO))
	
END