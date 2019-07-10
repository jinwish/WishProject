#!/usr/bin/env python
# -*- coding: utf-8 -*-
import unreal_engine as ue
from unreal_engine import SWindow, SButton, SHorizontalBox, FARFilter

# 한글 문자열 수집을 위해 필요함
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

#윈도우 하나만 사용 하자!!! // Error가 있음
#if window != None:
#	window.request_destroy()

window = SWindow(client_size=(330, 32), title='Widget Blueprint To Text', sizing_rule=0)(
	SHorizontalBox()
	(
		SButton(text='전체 WBP 추출', on_clicked=lambda: WBPall())
	)
	(
		# 함수에 연결된 버튼
		SButton(text='선택한 WBP 추출', on_clicked=lambda: WBPsel())
	)
	(
		SButton(text='WBP텍스트 지우기', on_clicked=lambda: Wtestxx())
	)
)

# 테스트설정
def Wtestxx():
	selbp = ue.get_selected_assets()
	for aa in selbp:
		aa.save_package()
		uw = aa.WidgetTree
		allwid = uw.AllWidgets
		for wb in allwid:
			if wb.get_class().get_name() == 'TextBlock':
				try:
					ue.log(wb.get_name())
					wb.Text = ''
				except:
					ue.log('Error!!')
			if wb.get_class().get_name() == 'IMTextBlock':
				try:
					ue.log(wb.get_name())
					ue.log(wb.Content)
					wb.Content = ''
				except:
					ue.log('Error!!')
		ue.compile_blueprint(aa)
		aa.save_package()
		#for w in wb.properties():
		#	ue.log(w)
		#ue.log('_______________________________________________')

# 전체 위젯블루프린트를 가져온다.
def WBPall():
	try:
		filename = unreal_engine.save_file_dialog('Save a Text file', '', '', 'TXT|*.txt')[0]	
		# 클래스 네임으로 가져온다
		wbp = ue.get_assets_by_class('WidgetBlueprint')
		settext = []
		count = 0
		startline = '위젯블루프린트이름\t위젯오브젝트이름\t문자열\t폰트이름\tLocalKey\tLocalNameSpace\t기획 로컬 체크\t코드제어 여부\t비고\n'
		settext.append(startline)

		for wb in wbp:
			try:
				ue.log('{0} SaveText : {1}'.format(count, wb.get_name()))
				for i in WBAssetObj(wb):
					settext.append(i)
			except:
				ue.log('Error!! : {0}'.format(wb.get_name()))
			count = count + 1
		#텍스트파일 생성
		TextwriteAll(settext, filename)
	except:
		ue.log('### 저장을 취소하였습니다###')

# 선택한 위젯블루프린트를 가져온다.
def WBPsel():
	try:
		filename = unreal_engine.save_file_dialog('Save a Text file', '', '', 'TXT|*.txt')[0]
		selwb = ue.get_selected_assets()
		settext = []
		count = 0
		startline = '위젯블루프린트이름\t위젯오브젝트이름\t문자열\t폰트이름\tLocalKey\tLocalNameSpace\t기획 로컬 체크\t코드제어 여부\t비고\n'
		settext.append(startline)

		for wb in selwb:
			try:
				ue.log('{0} SaveText : {1}'.format(count, wb.get_name()))
				for i in WBAssetObj(wb):
					settext.append(i)
			except:
				ue.log('Error!! : {0}'.format(wb.get_name()))
			count = count + 1
		#텍스트파일 생성
		if len(settext) > 1:
			TextwriteAll(settext, filename)
		else:
			ue.log('### 저장 할 정보가 없습니다###')
	except:
		ue.log('### 저장을 취소하였습니다###')
		
#위젯블루프린트만 문자열값을 정리한다.
def WBAssetObj(getbp):
	asset = getbp #ue.get_selected_assets()[0]
	if asset.get_class().get_name() != 'WidgetBlueprint': return
	
	asset.save_package()
	uw = asset.WidgetTree
	allwid = uw.AllWidgets
	textwrites = ''
	alltext = []
	count = 0
	
	# TextBlock IMTextBlock 찾아서 정보를 수집 합니다
	for wb in allwid:
		textwrites = ''
		if wb.get_class().get_name() == 'TextBlock':
			try:
				textwrites = str(asset.get_name()) + '\t' + str(wb.get_name()) + '\t' + str(wb.Text) + '\t' + str(wb.Font.FontObject.get_name()) + '\n'
			except:
				#파이썬이 한글을 인식을 못 할 경우
				ue.log('- {} - 문자열을 인식 할 수 없습니다.'.format(wb.get_name()))
		if wb.get_class().get_name() == 'IMTextBlock':
			try:
				# 개행문자열을 잘라낸다.
				con = str(wb.Content)
				con = " ".join(con.split())
				
				# LocalNameSpace Int 값을 String 변경
				LocalNameSpaceString = LocalName(wb.LocalNameSpace)

				textwrites = str(asset.get_name()) + '\t' + str(wb.get_name()) + '\t' + con + '\t' + str(wb.ContentFont.FontObject.get_name()) + '\t' + str(wb.LocalKey) + '\t' + LocalNameSpaceString + '\n'
			except:
				#파이썬이 한글을 인식을 못 할 경우
				ue.log('- {} - 문자열을 인식 할 수 없습니다'.format(wb.get_name()))
		if textwrites != '':
			alltext.append(textwrites)
		
	for u in alltext:
		count = count + 1
	return alltext

#LocalNameSpace INT -> String변경
def LocalName (valint):
	localstring = str(valint)
	if valint == 2:
		localstring = 'Fellow'
	if valint == 4:
		localstring = 'UI Word'
	if valint == 5:
		localstring = 'Quest UI'
	if valint == 17:
		localstring = 'Mail'
	return localstring

# 텍스트 파일로 저장 합니다
def TextwriteAll(textstring, pathstring):	
	if len(textstring) == 0:
		ue.log('### 저장할 정보가 없습니다###') 
	else:
		ue.log('### 파일을 저장 합니다###')
		ue.log(pathstring)
		x = open(pathstring, 'w')
		for i in textstring: #range(0,co):
			x.write(i)
			ue.log(i) #저장할 문자열 확인
		x.close()
		ue.log('### 파일 저장 완료했습니다###')