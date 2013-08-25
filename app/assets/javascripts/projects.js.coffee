#getModuleForm = ( module ) ->
#	$(".collapse").collapse('hide')
#	$("##{module}").collapse('show')


getModuleForm = ( module, project ) ->
  $.ajax(url: "/extensions/#{project}/#{module}", dataType: 'html').done (html) ->
	  $("#module-form").html html

 
$ ->
	$("select.module").change ->
		module = $(this).val()
		project = $(this).attr('id')
		getModuleForm( module, project )