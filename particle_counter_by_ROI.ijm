macro "particleToRoi" {

	
	
	
	//input = "/Users/moonbi/Documents/files/document/문서v3/MGI/Data/immunofluorescence/230529 RUSH SCOTIN Time point condition/puncta cell count/230613 puncta cell count T-15/Green"; //분석할 폴더
	//output = "/Users/moonbi/Documents/files/document/문서v3/MGI/Data/immunofluorescence/230529 RUSH SCOTIN Time point condition/puncta cell count/230613 puncta cell count T-15/Green/"; //내보낼 위치
	outputSummaryDataFileName = "analysis result";	//내보낼 파일의 이름
	//outputResultDataFileName = "puncta properties";
	suffix = ".czi" //분석할 파일의 확장자명
	saveSuffix = "tif" //내보낼 파일의 확장자명
	bncMin = 0; //밝기 조정 min
	bncMax = 65; //밝기 조정 max
	
	minThresholdROI = 30; //minimum threshold
	maxThresholdROI = 255; //maximum threshold
	minParticleROI = 10; //particle size threshold, min (>10 for DAPI, 63x)
	maxParticleROI = "Infinity"; //particle size threshold, max
	minCircularityROI = 0; //particle circularity, min
	maxCircularityROI = 1; //particle circularity, max
	
	minThresholdParticle = 90; //minimum threshold
	maxThresholdParticle = 255; //maximum threshold
	minParticleParticle = 0.01; //particle size threshold, min (>10 for DAPI)
	maxParticleParticle = 1; //particle size threshold, max
	minCircularityParticle = 0.1; //particle circularity, min
	maxCircularityParticle = 1; //particle circularity, max
	
	
	analysisPropertyROI = "size=" + minParticleROI + "-" + maxParticleROI + "circularity=" + minCircularityROI + "-" + maxCircularityROI + "bins=20 show=[Overlay Masks] noting clear record";
	analysisPropertyParticle = "size=" + minParticleParticle + "-" + maxParticleParticle + "circularity=" + minCircularityParticle + "-" + maxCircularityParticle + "show=[Overlay Masks] display summarize";
	
	print("initiating puncta counting macro...");
	//print("Target directory: " + input + "\n" + "Output data will save (overwrite) at: " + output + outputSummaryDataFileName + ".csv, " + outputResultDataFileName + ".csv");
	run("Clear Results");
	run("Bio-Formats Macro Extensions");
	//run("Excel Macro Extensions");
	processFolder(input);
	
	function processFolder(input) {
		input = getDirectory("home");
		Dialog.create("Particle Analysis");
		Dialog.addDirectory("image folder path", input);
		Dialog.show();
		input = Dialog.getString();
		
		//resultLocation = input + File.separator + "results";
		resultLocation = input + "results";
		File.makeDirectory(resultLocation);
		area_results = newArray();
		list = getFileList(input);
		roiBoolean = getBoolean("Do you need ROI check before each analysis?");
		for (i = 0; i < list.length; i++) {
			if(File.isDirectory(input + list[i]))
				processFolder("" + input + list[i]);
			if(endsWith(list[i], suffix))
				processFile(input, input, list[i]); //개별 이미지에 대한 프로세스
			else 
				i++;
			};
		selectWindow("Summary");
		saveAs("Results",  input + "results/" + outputSummaryDataFileName + ".csv");
//		selectWindow("Results");
//		saveAs("Results",  output + "/results/" + outputResultDataFileName + ".csv");
		run("Clear Results");
		print("Data saved at" + input + "results/" + outputSummaryDataFileName + ".csv");
		print("Data saved at" + input + "results/" + outputResultDataFileName + ".csv");
		print("Processing finished");
		};
	
	function processFile(input, output, file) {
		MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"); // Generate month names
		DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat"); // Generate date names
		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec); // Get date and time information
		
		location = input + "/" + file;
		fileItem = file;
		//open(location);
		Ext.openImagePlus(location);
		setOption("ScaleConversions", true);
		run("8-bit");
		setMinAndMax(bncMin, bncMax);
		run("Apply LUT");
		setThreshold(minThresholdROI, maxThresholdROI, "raw");
		run("Analyze Particles...", analysisPropertyROI); //particle property setting
		roiManager("reset");
		array1 = newArray("0"); 
		for (t=0; t<nResults; t++) {
	    	x = getResult("XStart", t);
	    	y = getResult("YStart", t);
	    	doWand(x,y);
	    	roiManager("add");
			};
		if (roiBoolean == 1) {
			waitForUser("Choose your ROI through ROIManager. Press OK if you are ready.");
			processROI(location);
			};
		if (roiBoolean == 0) {
			processROI(location);
			};
		};
		
		function processROI(filelocation) {
			close();
			if (roiManager("count") > 0) {
				Ext.openImagePlus(location);
				setOption("ScaleConversions", true);
				run("8-bit");
				setMinAndMax(bncMin, bncMax);
				run("Apply LUT");
				n = roiManager("count");
				for (m = 0; m < n; m++) {
				    roiManager("select", m);
				    // processing particle by each roi
					setThreshold(minThresholdParticle, maxThresholdParticle, "raw");
					run("Analyze Particles...", analysisPropertyParticle); //particle property setting
					//setResult("Area", row, value);
					//processing roi
		//			selectImage(fileItem);
		//			newName = fileItem + "_processed_" + m;
		//			saveAs(saveSuffix, input + "/results/" + newName);
					
				};
				close();
				};
			if (roiManager("count") == 0) {
				print("no ROI has detected in " + filelocation);
				};
			};
	
};