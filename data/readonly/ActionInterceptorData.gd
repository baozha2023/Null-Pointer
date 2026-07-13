## read only data for a type of action interceptor
extends SerializableData
class_name ActionInterceptorData

enum INTERCEPTOR_SCOPES {
	PARENT_ONCE,
	PARENT_PER_TARGET,
	TARGET,
}

@export var action_interceptor_script_path: String = ""	# script of the BaseActionInterceptor determining behavior of the interceptor
@export var action_intercepted_action_paths: Array[String] = []	# array of action script paths which will be intercepted by this interceptor
@export var action_interceptor_scope: int = INTERCEPTOR_SCOPES.PARENT_PER_TARGET
@export var action_interceptor_priority: int = 0	# determines the ordering of how interceptors are processed with respect to others. Higher priorites processed first. Use widely spaced multi digit priorities like 1000, instead of 1,2,3, to allow more room for injecting new ones later
