USE [ExPle_DEV]
GO
/****** Object:  StoredProcedure [mesuser].[SP_DASH_POP_LIST]    Script Date: 2023-03-22 오전 9:31:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************************	
	■ 프로시저	: SP_DASH_POP_LIST
	■ 작성목적	: POP-번호 검색 팝업창 Grid
	■ 실행예제	: 
				  
				  EXEC mesuser.SP_DASH_POP_LIST '','', '',''
	
	■ 비    고 : 
	 

	■ 주요변경내역    
	VER        DATE			AUTHOR				DESCRIPTION
	---------  ----------	---------------		------------------------------- 
	1.0        2023-01-15   홍승진	     	    1. 신규 생성
	1.1        2023-03-16   홍승진	     	    1. POP번호 중복 제거
												2. MACHINE_NAME 컬럼 제외.
*******************************************************************************************/
ALTER PROCEDURE [mesuser].[SP_DASH_POP_LIST]
	@POP_NO NVARCHAR(20) --  POP 번호
AS
BEGIN	

	SET NOCOUNT ON;

	select  
	    MAX(MAKER) AS MAKER      -- 제조사
	    , PPC_NO   AS PPC_NO     -- POP번호
	    -- ,  MAX(MACHINE_NAME)  -- 설비명칭
	from mesuser.MI_MACHINE
	where PPC_NO is not null  and PPC_NO <>''

	AND ( isnull(@POP_NO ,'')='' OR (PPC_NO LIKE '%'+@POP_NO+'%'))
	-- order by maker, PPC_NO, MACHINE_NAME 
	group by PPC_NO
	order by maker, PPC_NO
END