-- Save File UTF16
-- 변수
sloptival = 100.0
lbs00 = ""
lbs01 = "최적화 Faces : "
optival = true
useselset = false
openfilepath = "E:\EnpcFBX\Game\Assets\Characters\ENPC"
savefilepath = "D:\ExportFBX"
ClampMin = 1000
ClampMax = 10000
FixedOpti = 100.0
RatioOpti = 100.0

filename_array = #()
filepath_array = #()

clearListener()

-- 함수--------------------------------------------------------------------------------------
	
-- Auto Export FBX
	fn AutoPlay =
	(
		s = 1
		files = #()
		filepath_array = GetAllSubDirs_fn(openfilepath)
		for i = s to filepath_array.count do
		(
			if ((getfiles (filepath_array[i] + "*.max")).count != 0) do
			(
			files = getFiles (filepath_array[i] + "*.max")
						
				for f in files do
				(
					-- 3Dmax 파일 로드
					LoadMax f
					
					format "Load 3DMax File : %\n" maxFileName
					
					-- 메쉬 최적화
					if SetParameterPolyOpti (Objects) != undefined
					then
					(
						SetParameterPolyOpti (Objects)
						if $ != undefined then
						(
							format "Poly Count : % , Name : %\n"(getPolygonCount $)[1] ($.name)
						)
						else
						(
							format "Not Selet Object\n"
						)
						
						-- FBX 익스포트
						filename = getFilenameFile(maxFileName)
						ExportFBX savefilepath filename
					)
					else
					(
						format "Error!!!! Not Skin Mesh : %\n" maxFileName
					)
				)
			)
		)
	)

-- Auto Export FBX	Use Selection Set
	fn AutoPlayUseSelectionSet =
	(
		s = 1
		files = #()
		filepath_array = GetAllSubDirs_fn(openfilepath)
		for i = s to filepath_array.count do
		(
			if ((getfiles (filepath_array[i] + "*.max")).count != 0) do
			(
			files = getFiles (filepath_array[i] + "*.max")
				print files.count
				for f in files do
				(
					-- 3Dmax 파일 로드
					LoadMax f
					
					format "Load 3DMax File : %\n" maxFileName
					
					-- 메쉬 최적화
					if selectionSets.count == 0 do
					(
						format "Error!!!! No selectionSets : %\n" maxFileName
						resetMaxFile #noPrompt
						continue undefined
					)
										
					for s = 1 to selectionSets.count do
					(
						print (selectionSets[s].name)
						if selectionSets[s].count == 0 do
							continue undefined
						
						if SetParameterPolyOpti (selectionSets[s]) != undefined
						then
						(
							hide objects
							unhide selectionSets[s]
							
							SetParameterPolyOpti (selectionSets[s])
							if $ != undefined then
							(
								format "Poly Count : % , Name : %\n"(getPolygonCount $)[1] ($.name)
							)
							else
							(
								format "Not Selet Object\n"
							)
							-- FBX 익스포트
							select selectionSets[s]
							ExportFBX savefilepath selectionSets[s].name
							hide objects
						)
						else
						(
							format "Error!!!! Not Skin Mesh : %\n" maxFileName
						)
					)
				resetMaxFile #noPrompt
				)
			)
		)
	)
-- Rooy Dumy Delete
	fn RootDumyDelete delname =
	(
		for o in objects do
		(
			if (classof o) == Dummy do
			(
				if o.name == "Root" do
				(
					select o
					max unlink
				)
			)
			if (classof o) == Editable_mesh do
			(
				select o
				max unlink
			)
			/*
			if (classof o) == Dummy do
			(
				if (o.name == delname) do
				(
					deselect o
--					delete $
				)
			)
			*/
		)
		
		select objects
		deobj = getNodeByName(delname)
		deselect deobj
	)
	
-- Seletal Object
	fn SeleteObject =
	(
		obj = FindObj Objects
		if obj != undefined do
		(
			select obj
		)
	)
	
-- 선택 익스포트를 하기위해 선택을 한다.
	fn SelectionGroup setindex =
	(
		if selectionSets.count == 0 do
			return undefined
		
		hide objects
		unhide selectionSets[setindex]
		select selectionSets[setindex]
	)
	
-- Face 카운트
	fn GetPolyCount obj =
	(
		num_faces = getPolygonCount obj
		if (lbs00 == "") 
		then
		(
			lbs00 = "원   본 : " + num_faces[1] as string + " face"
		)
		else
		(
			lbs01 = "최적화 : " + num_faces[1] as string + " face"
		)
	)
	
-- 자동화에 파라메터 적용 및 폴리곤 최적화
	fn SetParameterPolyOpti objs =
	(
		o = FindObj objs
		if (o == undefined) do
		return undefined
		
		select o
		optiper = 100.0
		SetProOptimizer o optiper -- 폴리곤 카운트 리셋
		num_faces = getPolygonCount o
		print num_faces[1]
			
		if num_faces[1] < ClampMin do 
		(
			optiper = 100.0
		)
		if num_faces[1] > ClampMax
		then
		(
			optiper = float(ClampMax) / float(num_faces[1]) * 100.0
			SetProOptimizer o optiper
			num_faces = getPolygonCount o
			format "% : %\n" optiper num_faces[1]
		)
		else
		(		
			if (optival == true)
			then
			(
				optiper = FixedOpti
			)
			else
			(
				-- 비율로 폴리곤을 줄인다.
				optiper = (float(num_faces[1]) / float(ClampMax)) * (100.0 - RatioOpti) + RatioOpti
			)
			SetProOptimizer o optiper
		)
	)		
	
-- ProOptimizer 스택 설정
	fn SetProOptimizer obj Vertexp = 
	(
		try(
		if (obj == undefined) do
		( 
			return undefined
		)
		if (obj.modifiers[#ProOptimizer] == undefined) do
		(
			max modify mode
			modPanel.setCurrentObject $.baseObject
			modPanel.addModToSelection (ProOptimizer ()) ui:on
		)
		update obj
		obj.modifiers[#ProOptimizer].Calculate = true
		obj.modifiers[#ProOptimizer].OptimizationMode = 1
		obj.modifiers[#ProOptimizer].LockMat = true
		obj.modifiers[#ProOptimizer].KeepUV = true
		obj.modifiers[#ProOptimizer].ToleranceUV = 1.0
		
		obj.modifiers[#ProOptimizer].VertexPercent = 100.0
		num_faces = getPolygonCount obj
		lbs00 = "원   본 : " + num_faces[1] as string + " tris"
		
		obj.modifiers[#ProOptimizer].Calculate = true
		obj.modifiers[#ProOptimizer].VertexPercent = Vertexp
		num_faces = getPolygonCount obj
		lbs01 = "최적화  : " + num_faces[1] as string + " tris"
		
		
		)
		catch
		(
			format "Error : %\n" Maxfilename
		)
	)

-- 하위 디렉토리 까지 읽어온다.
	fn GetAllSubDirs_fn MyDirectory =
	(
	temp = #();
	s = 1;
	folders = getDirectories (MyDirectory + "/*");
	t = folders.count;
		while s < t do
		(
		for i = s to t do (temp = getDirectories (folders[i]+"*");
		for j = 1 to temp.count do folders[folders.count+1] = temp[j] );
		s = t;
		t = folders.count;
		)
	sort folders
	return folders;
	)
	
-- 열려있는 Max File 내에 특정 오브젝트를 찾아낸다.
	fn FindObj objs =
	(
		allobj_array = objs
		for obj in allobj_array do
		(
			if (obj.modifiers[#Skin] != undefined) do
			(
--				print (obj)
				return obj
			)
		)
		return undefined
	)
	
-- 3DMAX File 오픈 및 오픈시 옵션
	fn LoadMax loadstring =
	(
		resetMaxFile #noPrompt
		loadMaxFile loadstring quiet:true
	)
	
-- FBX Export 옵션
	fn ExportFBX savepath filenames =
	(
		--Geometry------------------------------------------------------------------------
		FBXExporterSetParam "SmoothingGroups" true
		FBXExporterSetParam "NormalsPerPoly" false
		FBXExporterSetParam "TangentSpaceExport" false
		FBXExporterSetParam "SmoothMeshExport" false
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
		
		print (savepath + "\\" + filenames + ".fbx")
		exportFile (savepath + "\\" + filenames + ".fbx") #noPrompt quiet:true selectedOnly:true
		
		--resetMaxFile #noPrompt
	)
-- FBX Import 옵션
	fn ImportFBX loadpath =
	(
		resetMaxFile #noPrompt
		--Geometry------------------------------------------------------------------------
		FBXExporterSetParam "SmoothingGroups" true
		FBXExporterSetParam "NormalsPerPoly" false
		FBXExporterSetParam "TangentSpaceExport" false
		FBXExporterSetParam "SmoothMeshExport" false
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
		--UI----------------------------------------------------------------
		FBXExporterSetParam "ShowWarnings" false
		FBXExporterSetParam "GenerateLog" false
		
		importFile loadpath #noPrompt
		
		deldumy = getFilenameFile(loadpath)
			
		RootDumyDelete deldumy
		
		savep = getFilenamePath(loadpath) + deldumy + ".max"
		print (savep)
			
		saveNodes selection savep --#noPrompt quiet:true
	)


-- 롤아웃 메뉴 
	rollout Add_Menu00 "Mesh Optimizer" category:1
	(
		spinner spval00 "Optimizer %:" range:[0,100,100] type:#float align:#left 
		slider sl00 "" orient:#horizontal ticks:0 range:[10,100,100] 
		button optistart "Selet Otimizer" border:true align:#left 
		label lb00 "원   본 : "align:#left
		label lb01 "최적화 : "align:#left
		-- 오픈 경로

		-- 최적화 %
		on spval00 changed val do 
		(
			sloptival = val
			sl00.value = val
		)
		-- 최적화 % 슬라이더
		on sl00 changed val do 
		(
			sloptival = val
			spval00.value = val
		)
		--  선택한 Object Mesh 최적화	
		on optistart pressed do 
		(
			selobj = $
			if (selobj == undefined) do
			(
				lb00.text = "원   본 : - "
				lb01.text = "최적화 : - "
				return undefined
			)
			
			SetProOptimizer selobj sloptival	
			
			lb00.text = lbs00
			lb01.text = lbs01
		)
	)

	rollout Add_Menu01 "Auto Optimizer" category:1
	(
		edittext openpath "Open Path" fieldWidth:125 labelOnTop:true
		button openbnt "..." border:true offset:[70,-25]
		edittext savepath "Save Path" fieldWidth:125 labelOnTop:true
		button savebnt "..." border:true offset:[70,-25]
		
		spinner spval01 "Pass Min poly<=" range:[0,100000,1000] type:#integer align:#right
		spinner spval02 "Clamp Max poly>=" range:[0,100000,10000] type:#integer align:#right
		spinner spval03 "Fixed Opti % :" range:[5,100,100] type:#float align:#right
		spinner spval04 "Ratio Opti % :" range:[5,100,100] type:#float align:#right
		--spinner spval05 "Fixed " range:[0,100,100] type:#float align:#right
		
		checkbox cb00 "" offset:[162,-40] checked:true
		checkbox cb01 "" offset:[162,0] checked:false
		checkbox cb02 "Use Named Selection Sets" checked:false --offset:[162,0]
		button autostart "Auto Otimizer Exprot" border:true align:#left 
		
		on openbnt pressed do 
		(
			openfilepath = getSavePath caption:"my title" initialDir:(getDir #maxroot)
			if (openfilepath != undefined) do
			(
				openpath.text = openfilepath
			)
		)
		
		on openpath entered txt do
		(
			if (openfilepath == undefined) do
			(
				return undefined
			)
			openfilepath = txt
		)
		
		on savepath entered txt do
		(
			if (savefilepath == undefined) do
			(
				return undefined
			)
			savefilepath = txt
		)
		
		on savebnt pressed do 
		(
			savefilepath = getSavePath caption:"my title" initialDir:(getDir #maxroot)
			if (savefilepath != undefined) do
			(
				savepath.text = savefilepath
			)
		)
		
		on spval01 changed val do 
		(
			ClampMin = val
		)
		
		on spval02 changed val do 
		(
			ClampMax = val
		)
		
		on spval03 changed val do 
		(
			FixedOpti = val
		)
		
		on spval04 changed val do 
		(
			RatioOpti = val
		)
		
		on cb00 changed val do
		(
			if(val) do
			(
				cb01.state = false
			)
			optival = cb00.state;
		)
		on cb01 changed val do
		(
			
			if(val) do
			(
				cb00.state = false
			)
			optival = cb00.state;
		)
		
		on cb02 changed val do
		(
			useselset = val
		)
		
		on autostart pressed do 
		(
			if useselset then
			(
				AutoPlayUseSelectionSet()
			)
			else
			(
				AutoPlay()
			)
		)
	
	)
	
	rollout Add_Menu02 "IcarusM TA Part" category:1
	(
		label me00 "IcarusM TA Jinwish@naver.com"align:#left
--		button TestFN "Test Bnt 입니다" border:true align:#left 
--		button fbxtomax "FBX => MAX 변환" border:true align:#left 
		
		on TestFN pressed do 
		(
--			SetProOptimizer $ 80
--			modPanel.setCurrentObject $
--			addmodifier $ (ProOptimizer () )
			ExportFBX savefilepath maxfilename
			--SeleteObject() 
			--exportFile (savefilepath + "\\" + getFilenameFile(maxFileName) + ".fbx") #noPrompt quiet:true selectedOnly:true
		)
		on fbxtomax pressed do
		(
			filepath_array = GetAllSubDirs_fn(openfilepath) 
			for i = 1 to filepath_array.count do
			(
				if ((getfiles (filepath_array[i] + "*.fbx")).count != 0) do
				(
					files = getFiles (filepath_array[i] + "*.fbx")
						
					for f in files do
					(
						print f
						ImportFBX f
					)
				)
			)
		)
	)
	--createDialog MeshOpti_Menu 150 180
	MeshOpti_Menu = newRolloutFloater "Mesh Optimizer" 200 420 30 50
	addRollout Add_Menu00 MeshOpti_Menu
	addRollout Add_Menu01 MeshOpti_Menu -- rolledUp:true
	addRollout Add_Menu02 MeshOpti_Menu rolledUp:true
	
