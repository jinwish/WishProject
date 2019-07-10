macroScript IM_FBXExport category:"im_util" --some macro script
(

clearListener()
--변수
savepathfile = ""
savepathfbx = ""
selsetname = "Export_All"
skinmeshname = ""
selectionSetsname = ""
skincount = 0
vertexcolorsw = false

-- 악성콜백 제거
	fn removebadcallback = 
	(
		callbacks.removeScripts id:#CRP_BScript
		callbacks.removeScripts id:#AutodeskLicSerStuckCleanBeta
	)
	
-- FBX Export 옵션
	fn ExportFBX savepath filenames =
	(
		removebadcallback()
		--Geometry------------------------------------------------------------------------
		FBXExporterSetParam "SmoothingGroups" true
		FBXExporterSetParam "NormalsPerPoly" false
		FBXExporterSetParam "TangentSpaceExport" true
		FBXExporterSetParam "SmoothMeshExport" true
		FBXExporterSetParam "Preserveinstances" false
		FBXExporterSetParam "SelectionSetExport" false
		FBXExporterSetParam "GeomAsBone" true
		FBXExporterSetParam "ColladaTriangulate" false
		FBXExporterSetParam "PreserveEdgeOrientation" true
		--Animation------------------------------------------------------------------------
		FBXExporterSetParam "Animation" false
		--Cameras------------------------------------------------------------------------
		FBXExporterSetParam "Cameras" false
		--Lights------------------------------------------------------------------------
		FBXExporterSetParam "Lights" false
		--Embed Media--------------------------------------------------------------------
		FBXExporterSetParam "EmbedTextures" false
		--Units----------------------------------------------------------------------------
		--Axis Conversion-----------------------------------------------------------------
		FBXExporterSetParam "AxisConversionMethod" "None"
		FBXExporterSetParam "UpAxis" "Y" 
		--UI----------------------------------------------------------------
		FBXExporterSetParam "ShowWarnings" false
		FBXExporterSetParam "GenerateLog" false
		--FBX File Format----------------------------------------------------------------
		FBXExporterSetParam "ASCII" false
		FBXExporterSetParam "FileVersion" "FBX201200"
		
		print (savepath + "\\" + filenames + ".FBX")
		
		
		namestring = filterString filenames " "
		x = ""
		for i = 1 to namestring.count do
		(
			x = x + namestring[i]
		)
		exportFile (savepath + x + ".FBX") #noPrompt quiet:true selectedOnly:true
	)
	
	-- FBX Animation Clip Export 옵션
	fn ExportClipFBX savepath filenames =
	(
		removebadcallback()
		--Geometry------------------------------------------------------------------------
		FBXExporterSetParam "SmoothingGroups" false
		FBXExporterSetParam "NormalsPerPoly" false
		FBXExporterSetParam "TangentSpaceExport" false
		FBXExporterSetParam "SmoothMeshExport" false
		FBXExporterSetParam "Preserveinstances" false
		FBXExporterSetParam "SelectionSetExport" false
		FBXExporterSetParam "GeomAsBone" true
		FBXExporterSetParam "ColladaTriangulate" false
		FBXExporterSetParam "PreserveEdgeOrientation" false
		--Animation------------------------------------------------------------------------
		FBXExporterSetParam "Animation" true
		FBXExporterSetParam "BakeAnimation" true
		--Cameras------------------------------------------------------------------------
		FBXExporterSetParam "Cameras" false
		--Lights------------------------------------------------------------------------
		FBXExporterSetParam "Lights" false
		--Embed Media--------------------------------------------------------------------
		FBXExporterSetParam "EmbedTextures" false
		--Units----------------------------------------------------------------------------
		--Axis Conversion-----------------------------------------------------------------
		FBXExporterSetParam "AxisConversionMethod" "None"
		FBXExporterSetParam "UpAxis" "Y" 
		--UI----------------------------------------------------------------
		FBXExporterSetParam "ShowWarnings" false
		FBXExporterSetParam "GenerateLog" false
		--FBX File Format----------------------------------------------------------------
		FBXExporterSetParam "ASCII" false
		FBXExporterSetParam "FileVersion" "FBX201200"
		
		print (savepath + "\\" + filenames + "..FBX")
		
		
		namestring = filterString filenames " "
		x = ""
		for i = 1 to namestring.count do
		(
			x = x + namestring[i]
		)
		exportFile (savepath + x + ".FBX") #noPrompt quiet:true selectedOnly:true
	)
	
	-- 뛰워쓰기 삭제
	fn StringDel fs =
	(
		if (fs.count == 0) do
		(
			return "Error"
		)
		
		namestring = filterString fs " "
		x = ""
		for i = 1 to namestring.count do
		(
			x = x + namestring[i]
		)
		return x
	)
	
-- Max File - Skin Mesh가 두개 일 경우 체크 한다.
	fn FindObj objs =
	(
		allobj_array = objs
		skincount = 0
		findskinobj = undefined
		
		for obj in allobj_array do
		(
			
			if (obj.modifiers[#Skin] != undefined) do
			(
				skincount = skincount + 1
				findskinobj = obj
			)
		)
		if findskinobj == undefined
			then 
			(
				return undefined
			)
			else
			(
				return findskinobj
			)
		
	)
	
	-- 선택한 메쉬를 찾는다.
	fn FindSelObj objs selobj =
	(
		allobj_array = objs
		skincount = 0
		findskinobj = undefined
		
		for obj in allobj_array do
		(
			
			if (obj.modifiers[#Skin] != undefined) do
			(
				if (obj == selobj) do
				(
					skincount = skincount + 1
					findskinobj = obj
				)
			)
		)
		if findskinobj == undefined
			then 
			(
				return undefined
			)
			else
			(
				return findskinobj
			)
		
	)

-- 벌택스 채널 지움
	fn ChannellClear obj = 
	(
		select obj
		channelInfo.ClearChannel $ 6 -- UV 6 채널
		channelInfo.ClearChannel $ 5 -- UV 5 채널
		channelInfo.ClearChannel $ 4 -- UV 4 채널
		channelInfo.ClearChannel $ 3 -- UV 3 채널
		channelInfo.ClearChannel $ 2 -- UV 2 채널
--		channelInfo.ClearChannel $ 1 -- UV 1 채널
		if vertexcolorsw != true do
		(
			channelInfo.ClearChannel $ 0 -- 벌택스 컬러
		)
		channelInfo.ClearChannel $ -1 -- 벌택스 일루미네이션
		channelInfo.ClearChannel $ -2 -- 벌택스 알파
	)
	
	-- Normal 값 정형화
	fn MakeExplicitNormal selobj =
	(
		if (selobj == undefined) do
		(	
			return undefined
		)
				
		theMod=Edit_Normals()
					
		addModifier selobj theMod before:2	

		modPanel.setCurrentObject selobj.modifiers[#Edit_Normals]
					
		endnum = selobj.Edit_Normals.GetNumNormals()
					
					
		selobj.Edit_Normals.Select #{1..endnum}
		selobj.Edit_Normals.EditNormalsMod.MakeExplicit ()
					
										
		maxOps.CollapseNodeTo $ 2 true
	)

-- 모디파이 정리	
	fn DeleteModi obj =
	(
		for i = 1 to obj.modifiers.count do
		(
			if (obj.modifiers[#UVW_Mapping_Clear] != undefined ) do
			(
				deleteModifier obj 1
			)
		)
	)

	-- 레이어 당 해당 오브젝트 가져오기
	fn LayerCripSet =
	(
		for i = 0 to layerManager.count-1 do
		(
		  ilayer = layerManager.getLayer i
		  layerName = ilayer.name
		  layer = ILayerManager.getLayerObject i
		  layerNodes = refs.dependents layer
		  format "Layer: %; nodes: %\n" layerName layerNodes
			print layerNodes
		)
	)
	
	fn LoadMax loadstring =
	(
		resetMaxFile #noPrompt
		loadMaxFile loadstring quiet:true
		removebadcallback()
	)
	
	fn ExprotSkinMeshSet =
	(
		if maxFilePath == "" do
			return undefined
		
		skinmeshcount = 0
		if selectionSets.count == 0 do
		(
			messageBox "에러!!!! 셀렉션 셋이 없습니다!!!"
			return undefined
		)
			
		for i = 1 to selectionSets.count do
		(
			if (FindObj selectionSets[i]) != undefined
			then
			(
				hide objects
				unhide selectionSets[i]
				obj = FindObj selectionSets[i]
				skinmeshname = obj.name
				
				MakeExplicitNormal obj
				
				ChannellClear obj
								
				select selectionSets[i]
				
				/*
				format "100 :% , % \n "  maxFilePath selectionSets[i].name
				ExportFBX maxFilePath selectionSets[i].name
				*/
				-- 3Dmax File name
				-- format "100 :% , % \n "  maxFilePath (substituteString maxFileName ".max" "")
				--ExportFBX maxFilePath (substituteString skinmeshname ".max" "")
				
				if skincount > 1 do
				(
					overskincount = "경고!!! " + "{ " +selectionSets[i].name + " }" +  " : " + obj.name + "  2개 이상 Skin Mesh가 셀렉션 셋에 있습니다!!!"
					messageBox overskincount
				)
								
				-- 세이브 패스가 있으면 세이브 패스로 저장
				if savepathfbx == ""
				then
				(
					ExportFBX maxFilePath skinmeshname
				)
				else
				(
					ExportFBX savepathfbx skinmeshname
				)

				skinmeshcount = skinmeshcount + 1
				
				DeleteModi obj
			)
			else
			(
				format "Error Non Skin Mesh!!!!!\n"
			)
		)
		if skinmeshcount == 0 do
		(
			messageBox "에러!!!! 셀렉션 셋 스킨메쉬가 없습니다!!!"
		)
	)
	
	-- 선택한 스켈레탈 메쉬
	fn ExprotSelSkinMeshSet skinmesh =
	(
		selobj = skinmesh
						
		if maxFilePath == "" do
			return undefined
		
		if selobj.modifiers[#Skin] == undefined do
			return undefined
		
		skinmeshcount = 0
		if selectionSets.count == 0 do
		(
			messageBox "에러!!!! 셀렉션 셋이 없습니다!!!"
			return undefined
		)

		for i = 1 to selectionSets.count do
		(
			if (FindSelObj selectionSets[i] selobj) != undefined
			then
			(
				hide objects
				unhide selectionSets[i]
				obj = FindSelObj selectionSets[i] selobj
				skinmeshname = obj.name
				
				MakeExplicitNormal obj
				
				ChannellClear obj
				
				select selectionSets[i]
				/*
				format "100 :% , % \n "  maxFilePath selectionSets[i].name
				ExportFBX maxFilePath selectionSets[i].name
				*/
				-- 3Dmax File name
				-- format "100 :% , % \n "  maxFilePath (substituteString maxFileName ".max" "")
				--ExportFBX maxFilePath (substituteString skinmeshname ".max" "")
				
				if skincount > 1 do
				(
					overskincount = "경고!!! " + "{ " +selectionSets[i].name + " }" +  " : " + obj.name + "  2개 이상 Skin Mesh가 셀렉션 셋에 있습니다!!!"
					messageBox overskincount
				)
				
				-- 세이브 패스가 있으면 세이브 패스로 저장
				
				if savepathfbx == ""
				then
				(
					ExportFBX maxFilePath skinmeshname
				)
				else
				(
					ExportFBX savepathfbx skinmeshname
				)
				
				skinmeshcount = skinmeshcount + 1
				
				DeleteModi obj
			)
			else
			(
				format "Error Non Skin Mesh!!!!!\n"
			)
		)
		if skinmeshcount == 0 do
		(
			messageBox "에러!!!! 셀렉션 셋 스킨메쉬가 없습니다!!!"
		)
	)
	
-- Animation clip export
	fn ExprotAnimationClip nameset =
	(

		if maxFilePath == ""
		then(
			if savepathfile == "" do
			return undefined
		)
		else(
			savepathfile = maxFilePath
		)
	
			
		files = getfiles (savepathfile + "\*.max")
		for f in files do
		(
			LoadMax f

			if selectionSets.count == 0 do
			(
				messageBox "에러!!!! 셀렉션 셋이 없습니다!!!"
				return undefined
			)
				
			for i = 1 to selectionSets.count do
			(
				format "-------------- : %\n" selectionSets[i].name
				if selectionSets[i].name == nameset
				then
				(
					hide objects
					unhide selectionSets[i]

					select selectionSets[i]
					format "100 :% , % \n "  maxFilePath selectionSets[i].name
					if savepathfbx == ""
						then
						(
							ExportClipFBX maxFilePath  (substituteString maxFileName ".max" "") --selectionSets[i].name
						)
						else
						(
							ExportClipFBX (savepathfbx + "\\")  (substituteString maxFileName ".max" "") --selectionSets[i].name
						)
					--skinmeshcount = skinmeshcount + 1
					
					--DeleteModi obj
				)
				else
				(
					ps = maxFileName + " : Error!!! 셀렉션 셋에 같은 이름이 없습니다.\n" 				
					format "%\n"ps
					messageBox ps
				)
			)
		)
	)
	
	fn SingleExportAnimationClip nameset =
	(
		namecount = 0
		if selectionSets.count == 0 do
			(
				messageBox "에러!!!! 셀렉션 셋이 없습니다!!!"
				return undefined
			)
				
			for i = 1 to selectionSets.count do
			(
				if selectionSets[i].name == nameset do
				(
					hide objects
					unhide selectionSets[i]

					select selectionSets[i]
					format "100 :% , % \n "  maxFilePath selectionSets[i].name
					if savepathfbx == ""
						then
						(
							ExportClipFBX maxFilePath  (substituteString maxFileName ".max" "") --selectionSets[i].name
						)
						else
						(
							ExportClipFBX (savepathfbx + "\\")  (substituteString maxFileName ".max" "") --selectionSets[i].name
						)
					--skinmeshcount = skinmeshcount + 1
					
					--DeleteModi obj
						namecount = namecount + 1
				)
			)
			if namecount == 0 do
				(
					ps = maxFileName + " : Error!!! 셀렉션 셋에 같은 이름이 없습니다.\n" 				
					format "%\n"ps
					messageBox ps
				)
	)
-- 롤아웃 메뉴 
	rollout Add_Menu00 "FBX Exporter" category:1
	(
		checkbox vertexcbox "벌택스컬러ON (얼굴메쉬만사용)" checked: false tooltip:"얼굴메쉬만사용"
		button optistart "스켈레탈 메쉬 Export" border:true align:#left 
		button optselistart "선택한 스켈레탈 메쉬 Export" border:true align:#left 
		label lb00 "-------------------------------------"align:#left
		--label lb01 "-------------------------------------"align:#left
		button anistart "복수 애니메이션 클립 Export" border:true align:#left
		button singleani "단일 애니메이션 클립 Export" border:true align:#left
		edittext selset "export Selection Set Name" fieldWidth:125 labelOnTop:true text:"Export_All"
		edittext savepath "Save Path" fieldWidth:125 labelOnTop:true
		button savebnt "..." border:true offset:[70,-25]
		
		on vertexcbox changed theState do
		(
			vertexcolorsw = theState
		)
		on optistart pressed do 
		(
			try
			(
				ExprotSkinMeshSet()
			)
			catch()
		)
		on optselistart pressed do 
		(
			try
			(
				ExprotSelSkinMeshSet $
			)
			catch()
		)
		on anistart pressed do 
		(
			try
			(
				ExprotAnimationClip selsetname
			)
			catch()
		)
		on singleani pressed do
		(
			try
			(
				SingleExportAnimationClip selsetname
			)
			catch()
		)
		
		on savebnt pressed do 
		(
			savepathfile = getSavePath caption:"my title" initialDir:(getDir #maxroot)
			if (savepathfile != undefined) do
			(
				savepath.text = savepathfile
				savepathfbx = savepathfile
			)
		)
		
		on savepath entered txt do
		(
			if (savepath == undefined) do
			(
				return undefined
			)
			savepathfbx = txt
		)
		
		on selset entered txt do
		(
			if (selset == undefined) do
			(
				return undefined
			)
			selsetname = txt
		)
	)
	rollout Add_Menu01 "IcarusM TA Team" category:1
	(
		label me01 "FBX 익스포트 설정 되어 있습니다."align:#left
		label me02 "Skin Mesh 와 Animation Clip을 "align:#left
		label me022 "FBX로 익스포트 가능 합니다."align:#left
		label me03 "Skin Mesh - 셀렉션 셋으로 "align:#left
		label me033 "작동하고 하나의 파일내에 "align:#left
		label me04 "동시에 여러 FBX 익스포트 가능합니다."align:#left
		label me05 "Animation 클립은 지정한 셀렉션 셋만 "align:#left
		label me055 "FBX 로 익스포트 합니다."align:#left
		label me06 "MAX 파일을 저장 하지 않습니다. "align:#left
		label me066 "필요한 정보와 스킨 웨이트 값을 "align:#left
		label me0661 "손상시키지 않습니다."align:#left
		label me07 "Mesh 내부의 불필요 데이타를 정리 합니다."align:#left
		label me00 "IcarusM TA : 이진성"align:#left
		/*
		button tatest "Test" border:true align:#left 
		button vsfind "find" border:true align:#left 
		
		on tatest pressed do 
		(
			removebadcallback()
		)
		on vsfind pressed do 
		(
			va = globalVars.isGlobal #CRP_BScript
			vb = globalVars.isGlobal #AutodeskLicSerStuckCleanBeta
			if va == true or vb == true do
			(
				messageBox "max file에 악성코드가 있습니다!!!"
			)
		)
		*/
	)
	
	MeshOpti_Menu = newRolloutFloater "FBX Exporter" 200 250 30 50
	addRollout Add_Menu00 MeshOpti_Menu
	addRollout Add_Menu01 MeshOpti_Menu rolledUp:true

)


menuadd = true
mainMenu = menuMan.getMainMenuBar()
indexmenu = mainMenu.numItems()

for i = 1 to indexmenu do
(
	if (mainmenu.getitem i).getTitle() == "ICARUS M Tool" do
	(
		menuadd = false
	)
)
	
if menuadd == true do
(
theMainMenu = menuMan.getMainMenuBar() --get the main menu bar

theMenu = menuMan.createMenu "ICARUS M Tool" --create a menu called The Menu

theSubMenu = menuMan.createSubMenuItem "The Sub Menu" theMenu --create a SubMenuItem

theMainMenu.addItem theSubMenu (theMainMenu.numItems()+1) --add the SubMenu to the Main Menu

theAction = menuMan.createActionItem "IM_FBXExport" "im_util" --create an ActionItem from the MacroScript
theMenu.addItem theAction (theMenu.numItems()+1) --add the ActionItem to the menu

menuMan.updateMenuBar() --update the menu bar
)
