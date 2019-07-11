# -*- coding: utf-8 -*-
import unreal_engine as ue

# 한글 문자열 수집을 위해 필요함
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

# 해당 경로 에셋을 클래스이름으로 수집 (폴더 경로, 클래스 이름, 하위폴더 검색 여부)
class GetPathClass:
	def __init__(self, path, classname, bool):
		self.Asset_list = []
		self.GetfoderClass(path, classname, bool)

	def AssetListClear(self):
		self.Asset_list = []

	def GetfoderClass(self, folder_path, class_name, boolval):
		self.AssetListClear()
		pathasset = ue.get_assets(folder_path, boolval)
		for i in pathasset:
			if i.get_class().get_name() == class_name:
				self.Asset_list.append(i)

# 리스트 결과 값을 Text파일로 저장 (문자열리스트,저장경로)
class TextFileWrite:
	def __init__(self, stringlist, path):
		self.TextwriteAll(stringlist, path)

	def TextwriteAll(self,stringlist, path):	
		if len(stringlist) == 0:
			ue.log('### 저장할 정보가 없습니다###') 
		else:
			ue.log('### 파일을 저장 합니다###')
			x = open(path, 'w')
			for i in stringlist:
				x.write(str(i))
			x.close()
			ue.log('### 파일 저장 완료했습니다###')

# 리스트 값을 Text파일로 불러오기 (불러올 경로)
class TextFileRead:
	def __init__(self, path):
		self.Load_list = []
		self.TextReadAll(path)

	def GetStringArray(self):
		return self.Load_list

	def TextReadAll(self, path):	
		ue.log('### 파일을 불러옵니다 ###')
		line_list = []
		f = open(path, 'r')
		while True:
			line = f.readline()
			if not line: break
			self.Load_list.append(line.replace('\n', ''))
		f.close()
		if len(self.Load_list) == 0:
			ue.log('### Text 파일에 정보가 없습니다 ###')
		else:
			ue.log('### (' + str(len(self.Load_list)) + ') Line 불러오기 완료했습니다 ###')