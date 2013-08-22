#getModuleForm = ( module ) ->
#  $.ajax(url: "/module-forms/#{module}", dataType: 'html').done (html) ->
#	  $("#module-form").html html.substring(1,html.length-2)


 
getModuleForm = ( module ) ->
	$(".collapse").collapse('hide')
	$("##{module}").collapse('show')
 
$ ->
	$("select.module").change ->
		module = $(this).val()
		getModuleForm( module )