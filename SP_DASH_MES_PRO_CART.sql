USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_MES_PRO_CART]    Script Date: 2023-03-22 오전 9:26:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************************	
	■ 프로시저	: SP_DASH_MES_PRO_CART
	■ 작성목적	: 불량 현황(생산) / Tab2.불량유형 Chart & MiniGrid
	■ 실행예제	: 
				  
				  EXEC [mesuser].[SP_DASH_MES_PRO_CART]  '','','','',''
	
	■ 비    고 : 
	 

	■ 주요변경내역    
	VER        DATE			AUTHOR				DESCRIPTION
	---------  ----------	---------------		------------------------------- 
	1.0        2022-12-26	CHO Sang HO         1. 신규생성 .
	1.1        2023-03-15	홍승진              1. EOL_Result를 Union
*******************************************************************************************/
ALTER PROCEDURE [mesuser].[SP_DASH_MES_PRO_CART] 
	   @WORKDATE_S			NVARCHAR(20)		-- 시작일
	  ,@WORKDATE_E          NVARCHAR(20)		-- 종료일
	  ,@POPNO				NVARCHAR(20)		-- POP번호
	  ,@ITEMCODE            NVARCHAR(20)         --자재코드 
	  ,@Layer               NVARCHAR(20)         --층정보
AS
BEGIN
SELECT 
	DEFECT_NAME   -- 불량유형 
	, sum(SUM_BAD_QTY) as SUM_BAD_QTY  -- 불량수량
	, sum( Rate) aS Rate
	, sum(SUM_BAD_QTY)* 100 / sum(sum(SUM_BAD_QTY)) OVER() AS Rate_TOTAL  -- 불량율
	FROM(
		SELECT  DEFECT_NAME   -- 불량유형 
			, SUm(BAD_QTY) AS SUM_BAD_QTY
			, Convert(numeric(13,3), Round((SUm(BAD_QTY)/ (SUm(IN_QTY)+ SUm(BAD_QTY))) * 100,4)) as  Rate 
		FROM
		(
			SELECT *
			FROM
			(
				SELECT  
				--   CONVERT(CHAR(10), WR.WORKDATE, 23) AS WORKDATE -- 1.생산일자
					( Select 
						(select c_name from [mesuser].APP_LIBRARY_CODE where B_OID = MACHINE_LOCATION) as location
					from [mesuser].MI_MACHINE
					where MACHINE_CODE = WR.MACHINE) AS Layer  -- 2. 라인위치		
					, ISNULL(WR.[BAD_QTY],0)     as BAD_QTY      -- 불량수량
					, BD.DEFECT_CODE  as DEFECT_CODE      -- 불량 테이블 불량 코드
					, WR.[IN_QTY] as IN_QTY
					,( SELECT MI.DEFECT_NAME FROM  MI_DEFECT_TYPE MI WHERE MI.DEFECT_CODE= BD.DEFECT_CODE) AS  DEFECT_NAME -- 불량유형
					, (SELECT MA.PPC_NO    FROM [mesuser].MI_MACHINE     MA WhERE  MA.MACHINE_CODE=WR.MACHINE) AS POPNO   --3.POP 번호 POP_NO
				FROM [mesuser].[PP_WORK_RESULT] WR LEFT JOIN 
					 [mesuser].[PP_WORK_BAD] BD ON WR.ERP_ORDER_NO = BD.ERP_ORDER_NO
				WHERE 
					WR.B_USE =1
					AND WR.B_USE =1
					AND BD.BAD_QTY >0			
	    	        AND ( isnull(@WORKDATE_S,'')=''OR (WR.WORKDATE >= @WORKDATE_S))
                    AND ( isnull(@WORKDATE_E,'')=''OR (WR.WORKDATE <= @WORKDATE_E))
			        AND ( isnull(@ITEMCODE,'')=''OR  ( WR.ITEMCODE =@ITEMCODE))
            
				UNION 
				SELECT
					( Select 
							(select c_name 
							 from [mesuser].APP_LIBRARY_CODE 
							 where B_OID = MACHINE_LOCATION) AS location
						from [mesuser].MI_MACHINE
						where MACHINE_CODE = EOL.MACHINE) AS Layer	 -- 라인 위치
					, EOL.BAD_QTY AS BAD_QTY	-- 불량 수량
					, BD.DEFECT_CODE AS DEFECT_CODE	  -- 불량테이블 코드
					, EOL.IN_QTY AS IN_QTY 	-- 양품수량
					, ( SELECT MI.DEFECT_NAME FROM  MI_DEFECT_TYPE MI WHERE MI.DEFECT_CODE= BD.DEFECT_CODE) AS DEFECT_NAME 	--  불량유형
					,  (SELECT MA.PPC_NO    FROM [mesuser].MI_MACHINE  MA WHERE  MA.MACHINE_CODE = EOL.MACHINE) AS POPNO	  -- POP번호
				FROM [mesuser].[PP_EOL_RESULT] EOL LEFT JOIN
					 [mesuser].[PP_WORK_BAD] BD ON EOL.ERP_ORDER_NO = BD.ERP_ORDER_NO
				WHERE 
					BD.BAD_QTY >0	
	    	        AND ( isnull(@WORKDATE_S,'')=''OR (EOL.WORKDATE >= @WORKDATE_S))
                    AND ( isnull(@WORKDATE_E,'')=''OR (EOL.WORKDATE <= @WORKDATE_E))
					AND ( isnull(@ITEMCODE,'')=''OR  ( EOL.ITEMCODE =@ITEMCODE))
            
			) AS T
			Where  
			1=1
			AND ( isnull(@Layer,'')=''OR  ( Layer = @Layer))
			AND ( isnull(@POPNO,'')=''OR  ( POPNO =@POPNO))	
		) AS TB
		Where 
		1=1
		AND BAD_QTY  >0		

	GROUP BY DEFECT_NAME 
	) TT
GROUP by DEFECT_NAME
END
