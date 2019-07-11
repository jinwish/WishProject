# -*- coding: utf-8 -*-

class IMText:
	def __init__(self):
		self.tableHeader_01 = '번호'
		self.tableHeader_02 = '클래스'
		self.tableHeader_03 = '      어셋 폴더 경로       '
		self.tableHeader_04 = '이름'
		self.tableHeader_05 = '에셋유무'
		self.tableHeader_06 = '키워드'
		self.tableHeader_07 = '어셋선택'
		self.listHeader_01 = '테이블 이름 (xlsx파일)'
		self.listHeader_02 = '시트 이름'
		self.listHeader_03 = '컬럼 이름'
		self.listHeader_04 = '테이블 확인 (리소스비교)'

class IMResourceVol:
	def __init__(self):
		self.column_01 = '' #번호
		self.column_02 = '' #클래스이름
		self.column_03 = '' #어셋폴더경로
		self.column_04 = '' #어셋이름
		self.column_05 = '' #프로젝트 내부에 어셋유무
