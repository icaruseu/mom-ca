
// $(document).ready(function(){
//	 $('#graphics').has('.no-graphic').css( 'display', 'none');
//	 $('#tenor').has('#bibltenor').css( 'display', 'block');
// });


function changeImage(url){
	document.images["image"].src = url;
	document.getElementById('img-link').setAttribute('href', url);
  // reload SVG and cancel create- process
  jQuery(document).imageTool.resetSVGId();
  jQuery(document).imageTool.loadSVG();
}



function changeGraphic(wit, url)
{
	document.images[wit].src = url;
}



function showHideDiv(id, triangle)
{
	if(document.getElementById(id).style.display == "none")
	{
		document.getElementById(id).style.display = "block";
	}
	else
	{
		document.getElementById(id).style.display = "none";
	}
}



function hideDiv(id)
{
	document.getElementById(id).style.display = "none";
}



function showDiv(id)
{
	document.getElementById(id).style.display = "block";
}



function assignDiv(hide, show)
{
	var divs = new Array();
	divs = hide.split(' ');
	for (n = 0; n < divs.length; n++)
	{
		document.getElementsByName(divs[n])[0].style.backgroundColor = "";
		document.getElementsByName(divs[n])[0].style.color = "";
		document.getElementsByName(divs[n])[0].style.borderRight = "";
	}
	document.getElementsByName(show)[0].style.backgroundColor = "rgb(142,163,132)";
	document.getElementsByName(show)[0].style.color = "white";
	document.getElementsByName(show)[0].style.borderRight = "solid rgb(255,151,5) 6px";
}



function showContent(hide, show)
{
	var divs = new Array();
	divs = hide.split(' ');
	for (n = 0; n < divs.length; n++)
	{
		hideDiv(divs[n]);
	}
	showDiv(show);
	assignDiv(hide, show);
}
