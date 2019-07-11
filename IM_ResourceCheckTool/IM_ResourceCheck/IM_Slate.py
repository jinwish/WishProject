# -*- coding: utf-8 -*-
#!/usr/bin/env python

# 한글 문자열 수집을 위해 필요함
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import unreal_engine as ue
from unreal_engine import SWindow, SButton, STextBlock, SHorizontalBox, SVerticalBox, SGridPanel, SScrollBox, SBorder, SEditableTextBox, FLinearColor
from unreal_engine.enums import EHorizontalAlignment, EOrientation
from unreal_engine.structs import SlateColor

window = None
savelist = []

color_red = SlateColor(SpecifiedColor=FLinearColor(1, 0, 0))
color_default = SlateColor(SpecifiedColor=FLinearColor(1, 1, 1))
color_gray = SlateColor(SpecifiedColor=FLinearColor(0.5, 1.0, 0.5))
tablenametext = ''

# 테이블 만들기
class ClassTable:
	def __init__(self, text, textlist, tablename):
			tablenametext = tablename
			self.window = SWindow(client_size=(1024, 600), title= '리소스 검색 결과 창' + tablename)
			self.vertical = SVerticalBox()
			self.horizon = SHorizontalBox()
			self.scroll = SScrollBox(orientation=EOrientation.Orient_Vertical)

			self.chk_grid = SGridPanel()
			table_padding = (10, 5, 10, 5)
			btn_padding = (4, 4, 4, 4)
			savepath = ''
			savelist = []

			self.chk_grid.add_slot(SBorder(padding=btn_padding,v_align=2)(SButton(text='현재 리스트 TXT 파일로 저장', on_clicked=lambda: SaveText(textlist,tablenametext))), column=0, row=0, column_span=2)
			self.chk_grid.add_slot(SBorder(padding=table_padding,h_align=2,v_align=2)(STextBlock(text=text.tableHeader_01)), column=0, row=1)
			self.chk_grid.add_slot(SBorder(padding=table_padding,h_align=2,v_align=2)(STextBlock(text=text.tableHeader_02)), column=1, row=1)
			self.chk_grid.add_slot(SBorder(padding=table_padding,h_align=2,v_align=2)(STextBlock(text=text.tableHeader_05)), column=2, row=1)
			self.chk_grid.add_slot(SBorder(padding=table_padding,h_align=2,v_align=2)(STextBlock(text=text.tableHeader_04)), column=3, row=1)
			self.chk_grid.add_slot(SBorder(padding=table_padding,h_align=2,v_align=2)(STextBlock(text=text.tableHeader_03)), column=4, row=1)

			#두번째 row 부터 리스트를 작성 한다.
			i = 2

			for ttable in textlist: #range(1, 120):
				d = i
				color_val = color_gray
				stringsplit = ttable.split(',')
				name = stringsplit[0]
				path = stringsplit[1]
				assetname = stringsplit[2]
				uesasset = stringsplit[3]

				if '없음' == uesasset:
					color_val = color_red

				self.chk_grid.add_slot(SBorder(padding=table_padding,h_align=2,v_align=2)(STextBlock(text=str(i - 1))), column=0, row=i)
				self.chk_grid.add_slot(SBorder(padding=table_padding,h_align=2,v_align=2)(STextBlock(text=name)), column=1, row=i)
				self.chk_grid.add_slot(SBorder(padding=table_padding,h_align=2,v_align=2)(STextBlock(text=uesasset,color_and_opacity=color_val)), column=2, row=i)
				self.chk_grid.add_slot(SBorder(padding=table_padding,h_align=2,v_align=2)(STextBlock(text=assetname)), column=3, row=i)
				self.chk_grid.add_slot(SBorder(padding=btn_padding,v_align=2)(SEditableTextBox(text=path)), column=4, row=i)
				
				i += 1

			self.scroll.add_slot(self.chk_grid, auto_width = True, auto_hight = True)
			self.vertical.add_slot(SBorder()(self.scroll), auto_hight = True, padding=5)
			self.window.set_content(self.vertical)

# 저장 TEXT 다이얼로드
def SaveText(textstring,tablenametext):
	filename = ''
	try:
		filename = ue.save_file_dialog('Save a Text file', '', '', 'TXT|*.txt')[0]
	except:
		ue.log('### 저장을 취소하였습니다###')

	if '' != filename:
		TextwriteAll(textstring, filename,tablenametext)


# 리스트 결과 값을 Text파일로 저장 한다 (문자열리스트,저장경로)
def TextwriteAll(textstring, pathstring,tablenametext):	
	if len(textstring) == 0:
		ue.log('### 저장할 정보가 없습니다###') 
	else:
		ue.log('### 파일을 저장 합니다###')
		ue.log(pathstring)
		x = open(pathstring, 'w')
		x.write(tablenametext)
		for i in textstring: #range(0,co):
			x.write(i.split(',')[1] + '\n')
			ue.log(i) #저장할 문자열 확인
		x.close()
		ue.log('### 파일 저장 완료했습니다###')

# Text파일을 리스트로 반환 한다 (문자열리스트,불러오기경로)
def TextreadAll(pathstring):
	ue.log('### 파일 로드 완료했습니다###')