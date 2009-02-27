<cfcomponent>
  <cfset init() />

  <cffunction name="init" access="private" returntype="void">
    <cfset variables.model_path = request.path & 'model/' />
    <cfset variables.views_path = request.path & 'views/' />
    <cfset variables.controller_path = request.path & 'controllers/' />
    <cfset variables.routes_path = request.path & 'index.cfm/' />
    <cfset variables.before_filters = arrayNew(1) />
    <cfset variables.after_filters = arrayNew(1) />
  </cffunction>

	<cffunction name="execute" access="public" returntype="void">
		<cfargument name="action" required="yes" type="string" />
		
	  <cfset run(before_filters, arguments.action) />
		<cfinvoke method="#arguments.action#" />
	  <cfset run(after_filters, arguments.action) />
	</cffunction>

	<cffunction name="before" access="private" returntype="void">
		<cfargument name="actions" required="no" type="string" />
		<cfargument name="function" required="yes" type="string" />

		<cfset var filter = structCopy(arguments) />
		<cfset arrayAppend(variables.before_filters, filter) />
		
	</cffunction>
	
	<cffunction name="after" access="private" returntype="void">
		<cfargument name="actions" required="no" type="string" />
		<cfargument name="function" required="yes" type="string" />

		<cfset var filter = structCopy(arguments) />
		<cfset arrayAppend(variables.after_filters, filter) />
	</cffunction>
	
  <cffunction name="object" access="public" returntype="model">
    <cfargument name="name" type="string" required="yes" />

    <cfset var object = "" />

    <cfif structKeyExists(session, arguments.name)>
      <cfset object = session[arguments.name] />
      <cfset structDelete(session, arguments.name) />
    <cfelse>
      <cfset object = createObject('component', model_path & arguments.name) />
      <cfset object.init(request.dsn) />
    </cfif>

    <cfreturn object />
  </cffunction>

  <cffunction name="gateway" access="public" returntype="gateway">
    <cfargument name="name" type="string" required="yes" />

    <cfreturn createObject('component', model_path & arguments.name & '_gateway') />
  </cffunction>

  <cffunction name="render" access="private" returntype="void">
    <cfargument name="view" type="string" required="yes" />
    <cfargument name="layout" type="string" default="main" />

    <cfset content = "#views_path##prefix()#/#arguments.view#.cfm" />
    <cfinclude template="#views_path#layouts/#arguments.layout#.cfm" />
  </cffunction>

  <cffunction name="redirect_to" access="private" returntype="void">
    <cfargument name="action" type="string" required="yes" />

    <cflocation url="#routes_path##prefix()#/#arguments.action#" addtoken="no" />
  </cffunction>

  <cffunction name="path_to" access="private" returntype="string">
    <cfargument name="action" type="string" required="yes" />
    <cfargument name="controller" type="string" default="#prefix()#" />

    <cfreturn "#routes_path##controller#/#action#" />
  </cffunction>

  <cffunction name="prefix" access="private" returntype="string">
    <cfset var controller_name = listLast(getMetaData(this).name, '.') />
    <cfreturn left(controller_name, find('_', controller_name) - 1) />
  </cffunction>

  <cffunction name="message" access="private" returntype="void">
    <cfargument name="message" type="string" required="yes" />
    <cfargument name="type" type="string" default="notice" />

    <cfif not structKeyExists(session, 'messages')>
      <cfset session['messages'] = structNew() />
    </cfif>

    <cfif not structKeyExists(session['messages'], arguments.type)>
      <cfset session['messages'][arguments.type] = arrayNew(1) />
    </cfif>

    <cfset arrayAppend(session['messages'][arguments.type], arguments.message) />
  </cffunction>

  <cffunction name="run" access="private" returntype="void">
    <cfargument name="filters" type="array" required="yes" />
		<cfargument name="action" required="yes" type="string" />

    <cfset var appliesToAll = false />
    <cfset var appliesToCurrent = false />

    <cfloop from="1" to="#arrayLen(arguments.filters)#" index="i">
      <cfset appliesToAll = not structKeyExists(arguments.filters[i], 'actions') />
      <cfset appliesToCurrent = listFind(arguments.filters[i].actions, arguments.action) />

			<cfif appliesToAll or appliesToCurrent> 
        <cfinvoke method="#arguments.filters[i].function#" />
			</cfif>
		</cfloop>
  </cffunction>
</cfcomponent>
