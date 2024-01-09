--銷售區銷售匯總表

SELECT S.deptno, --部門別
       X.area, --銷售區
       X.trn, --異動代號
       SUM(X.freetax_saleamt) AS freetax_saleamt, --未稅銷貨總金額 
       SUM(X.medamt) AS medamt, --加藥總金額
       SUM(X.extraptg) AS extraptg, --加計運費
       SUM(disamt) AS disamt, --總折讓金額(扣繳金額)
       SUM(saletax) AS saleatax, --總稅額 
       SUM(salear) AS salear, --總應付金額
       SUM(ptgamt) AS ptgamt, --出貨總運費
       SUM(salewet) AS salewet  --總出貨重量
FROM
(
    SELECT L.area, --銷售區
           M.trn, --異動代號
           SUM(D.freetax_saleamt * V.sale_pn) AS freetax_saleamt, --SUM(未稅銷貨金額*銷貨存貨比) --未稅銷貨總金額 
           0 AS medamt, 
           0 AS extraptg, 
           0 AS disamt, 
           0 AS saletax, 
           0 AS salear, 
           0 AS ptgamt, 
           0 AS salewet
    FROM chd m  --出貨單主檔
    Left Join cdd D on m.dlvno = d.dlvno  --出貨明細
    Left Join cpl L on m.cusno = L.cusno AND M.prdline = L.prdline --客戶產品線
    Left Join ccm C on M.cusno = C.cusno --客戶基本資料
    Left Join voucode V on M.trn = V.trn --單據字軌
    WHERE 1 = 1
          AND M.dlvdate >='1121001'
          AND M.dlvdate <='1121031'
          AND M.trn >= '51'
          AND M.trn <= '57'
          AND M.voiddate = ''
          AND M.whno >='48'
          AND M.whno <='48'
          AND M.prdline >='1'
          AND M.prdline <='Z'
          AND ISNULL(C.rela_yn, 'N') >='N'
          AND ISNULL(C.rela_yn, 'N') <='Z'          
		  and l.area >='4'
		  and l.area <='5Z'
		  And M.dlvno>=''
		  And M.dlvno<='zzzzzzzzzz'
    GROUP BY L.area,M.trn

    UNION ALL
    SELECT L.area, --銷售區
           M.trn, --異動代號
           0 AS freetax_saleamt, --銷貨總金額
           SUM(ROUND((m.medamt * V.sale_pn) / (1 + tt.taxrate), 0)) AS medamt,  -- SUM((加藥金額*銷貨存貨比)/1+稅率) --加藥總金額(未稅)
           SUM(ROUND((ISNULL(G.extraptg, 0) * v.sale_pn) / (1 + tt.taxrate), 0)) AS extraptg,  --SUM(加計運費*銷貨存貨比/1+稅率) --加計運費(未稅)
           0 AS disamt, --總折讓金額
           SUM(M.saletax * v.sale_pn) AS saletax,  --SUM(稅額*銷貨存貨比) -- 總稅額
           SUM(M.salear * v.sale_pn) AS salear,  --SUM(應付金額*銷貨存貨比) -- 總應付金額
           SUM(ROUND(((ISNULL(G.realptg, 0) + ISNULL(G.alowptg, 0))) / (1 + tt.taxrate), 2)) AS ptgamt,  --SUM((實際運費+補貼運費)/1+稅率)  --總運費(未稅) 
           SUM(M.salewet * v.sale_pn) AS salewet  --SUM(出貨重量*銷貨存貨比)  --出貨總重量 
    FROM chd m --出貨單主檔
         LEFT JOIN chdptg G ON m.dlvno = g.dlvno --出貨運費
         LEFT JOIN cpl L ON M.cusno = L.cusno AND M.prdline = L.prdline --客戶產品線
         LEFT JOIN ccm C ON M.cusno = C.cusno  --客戶基本資料
         LEFT JOIN voucode V ON M.trn = V.trn  --單據字軌
         LEFT JOIN taxtype TT ON M.taxtype = tt.taxtype_no  --稅別
    WHERE 1 = 1
          AND M.dlvdate >='1121001'
          AND M.dlvdate <='1121031'
-- 1101222 加入 56,57異動
          AND M.trn >= '51'
          AND M.trn <= '57'
          AND M.voiddate = ''
          AND M.whno >='48'
          AND M.whno <='48'
          AND M.prdline >='1'
          AND M.prdline <='Z'
          AND ISNULL(C.rela_yn, 'N') >='N'  --關係企業否
          AND ISNULL(C.rela_yn, 'N') <='Z'
		  and l.area >='4'
		  and l.area <='5Z'
-- 1100709
And M.dlvno>=''
And M.dlvno<='zzzzzzzzzz'
    GROUP BY L.area,  --銷售區
             M.trn  --異動代號
    UNION ALL
    SELECT L.area,  --銷售區
           M.trn,  --異動代號
           0 AS freetax_saleamt,  --銷貨總金額 
           0 AS medamt,  --加藥金額
           0 AS extraptg,  --加計運費
           SUM(ROUND((ISNULL(G.useamt, 0) * v.sale_pn) / (1 + tt.taxrate), 0)) AS disamt,  --SUM(已使用金額*銷貨存貨比/1+稅率)  --折讓金額(未稅)
           0 AS saletax, --總稅額
           0 AS salear, --總應付金額
           0 AS ptgamt, --總運費
           0 AS salewet --出貨總重量
    FROM chd m
         LEFT JOIN chddis G ON m.dlvno = g.dlvno  --出貨折讓
         LEFT JOIN cpl L ON M.cusno = L.cusno AND M.prdline = L.prdline  --客戶產品線
         LEFT JOIN ccm C ON M.cusno = C.cusno  --客戶基本資料
         LEFT JOIN voucode V ON M.trn = V.trn  --單據字軌
         LEFT JOIN taxtype TT ON M.taxtype = tt.taxtype_no  --稅別
    WHERE 1 = 1
          AND M.dlvdate >='1121001'
          AND M.dlvdate <='1121031'
          AND M.trn >= '51'
          AND M.trn <= '57'
          AND M.voiddate = ''
          AND M.whno >='48'
          AND M.whno <='48'
          AND M.prdline >='1'
          AND M.prdline <='Z'
          AND ISNULL(C.rela_yn, 'N') >='N'
          AND ISNULL(C.rela_yn, 'N') <='Z'
		  and l.area >='4'
		  and l.area <='5Z'
		  And M.dlvno>=''
		  And M.dlvno<='zzzzzzzzzz'
    GROUP BY L.area, 
             M.trn
) AS X, 
salesman s  --業務代表資料
WHERE 1 = 1
      AND X.area = S.area  --銷售區
      AND S.prfno >=''  --利潤中心
      AND S.prfno <='zzz'
And X.area in('01','02','03','04','05','06','07','08','09','10','11','111','112','113','114','119','12','121','122','123','124','13','14','15','16','17','18','19','20','21','210','211','212','213','214','215','216','22','220','221','222','223','224','225','226','227','23','230','231','232','233','234','235','236','24','241','242','243','244','245','246','247','25','251','252','253','291','292','293','294','295','296','2A1','2B1','2B2','2B7','2D1','301','311','312','313','314','315','316','31A','31B','321','322','323','324','325','326','331','332','333','334','335','336','341','342','343','344','345','346','347','348','349','351','352','391','392','393','394','395','396','397','3A1','3B1','3B2','3B3','3B4','3B7','3D1','411','412','413','414','415','421','422','423','424','431','441','461','471','472','473','474','475','481','482','483','484','485','4B7','4B8','511','512','513','514','515','516','521','522','523','541','542','543','544','545','546','548','549','551','552','553','571','572','573','574','575','579','581','582','583','584','585','586','587','591','592','593','594','595','596','597','598','599','5A1','5A2','5A3','610','611','612','613','614','615','618','619','620','641','642','646','651','652','653','654','670','671','672','673','674','675','676','677','678','679','681','682','683','684','685','686','687','691','692','693','6A1','6A3','700','701','702','706','711','712','713','714','715','716','719','721','722','723','724','725','726','727','728','731','732','733','734','735','736','737','751','752','753','755','763','800','811','812','813','814','815','819','821','822','823','824','825','834','835','860','861','862','870','892','893','894','895','896','897','898','89A','89B','901','908','910','911','912','913','921','922','923','933','934','935','937','945','946','951','952','953','954','955','956','957','966','967','968','969','977','978','986','987','988','997','998','999','A01','A02','A03','B11','B12','B20','B21','B22','B23','B30','B38','C10','C11','C12','C13','C14','C15','C16','C17','C19','C1A','C1B','C1C','C1D','C1F','C20','C21','C22','C23','C24','C30','C31','C32','C33','C34','C40','C41','C42','C43','C44','C45','C50','C51','C52','C53','C60','C61','C62','C63','C69','C71','C72','C73','C74','C75','E01','F11','F12','F13','F22','F23','F24','G11','G12','G13','G15','G16','G17','G18','G19','G20','G21','G22','G23','G24','G25','G26','G27','G28','G29','G30','G31','G32','G33','G34','G35','G36','G37','G38','G50','G51','G52','G53','G54','G55','G60','G61','G62','G63','G64','G65','G66','G67','G68','G69','G70','G71','L11','L12','L13','L14','L15','L16','L21','L22','L23','L24','L25','M00','M01','M02','M03','M04','M10','M11','M12','M13','M14','M15','M16','M17','M19','M1A','M1B','M1C','M1D','M1F','M20','M21','M22','M23','M24','M25','M26','M30','M31','M32','M33','M34','M35','M36','M37','M39','M41','M42','M43','M44','M45','M46','M47','M48','M51','M52','M53','M54','M61','M62','M63','M64','M65','M66','M70','M71','M72','M73','M74','M81','M82','M83','M84','M85','M90','M91','M92','M93','M94','MA0','MA1','MA2','MA3','MB1','MB2','MB3','MD1','MD2','MD3','MF1','MF2','MF3','MG0','MG1','MG2','N10','N11','N12','N13','N14','N15','N16','N17','N19','N20','N21','N22','N30','N31','N32','N33','N34','N35','N36','N40','N41','N42','N43','N44','N45','N50','N51','N52','N53','N54','N71','N72','N81','P01','P02','P04','P06','P10','P11','P12','P13','P14','P15','P16','P17','P18','P19','P20','P21','P22','P23','P24','P25','P26','P27','P28','P29','P30','P31','P32','P33','P34','P35','P36','P37','P38','P39','P40','P41','P42','P43','P45','P46','P47','P48','P49','P50','P98','P99','Q01','Q02','Q03','Q04','Q05','Q06','Q07','Q11','Q99','R11','R12','R13','S01','S02','S03','S06','S07','S08','S09','S10','S11','S12','S13','S14','S15','S16','S17','S18','S20','S21','S22','S23','S30','S31','S32','S33','S34','S35','S36','S40','S41','S42','S43','S44','S45','S71','S72','S81','S82','S91','S92','S93','S94','S95','S97','T01','T02','T03','T06','T10','T101','T102','T103','T104','T105','T11','T12','T20','T200','T201','T202','T203','T204','T205','T299','T30','T301','T302','T303','T304','T311','T312','T313','T314','T315','T401','T402','T70','T701','XXX','Y01','Y02','Y03','Y04','Z91','Z92','Z93','Z94','Z95','Z96','ZZ1','ZZ2','ZZ3','ZZC','ZZS','ZZT','ZZU','ZZV','ZZW','ZZZ')
GROUP BY X.area, --銷售區
         X.trn, --異動代號
         S.deptno  --部門別
ORDER BY S.deptno,
         X.area, 
         X.trn;