extends RigidBody2D
class_name Platform

const VEL_CHANGE_WEIGHT = 0.1
const AIM_VEL_CHANGE_WEIGHT = 0.5

const ROT_CHANGE_WEIGHT = 0.1
const AIM_ROT_CHANGE_WEIGHT = 0.5

var aim_vel = Vector2(0, 0)
var vel = Vector2(0, 0)
var aim_rot = 0.0
var rot = 0.0


func _ready() -> void:
	custom_integrator = true


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	aim_vel = lerp(aim_vel, Vector2(0, 0), AIM_VEL_CHANGE_WEIGHT / mass)
	vel = lerp(vel, aim_vel, VEL_CHANGE_WEIGHT / mass)
	
	aim_rot = lerp(aim_rot, 0.0, AIM_ROT_CHANGE_WEIGHT / mass)
	rot = lerp(rot, aim_rot, ROT_CHANGE_WEIGHT / mass)
	
	state.linear_velocity = vel
	state.angular_velocity = rot
