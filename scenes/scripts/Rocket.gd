extends RotatableCharacterElement
class_name Rocket


const CONSTANT_FORCE = 1500
const STARTING_TIMER = 1.0
const RUNNING_TIMER = 5.0


@onready var particles: CPUParticles2D = $Particles
@onready var timer: Timer = $Timer
var running = false


func _stuck_process(delta: float):
	if running:
		stuck.aim_vel = Vector2(0, 1).rotated(rotation) * CONSTANT_FORCE / stuck.mass


func _collision_process(past_velocity: Vector2, collision: KinematicCollision2D, delta: float):
	super(past_velocity, collision, delta)
	
	if stuck == null:
		stick(collision.get_collider(), collision.get_normal())
		
		timer.start(STARTING_TIMER)
		await timer.timeout
		running = true
		
		SoundController.play_sfx("Rocket")
		timer.start(RUNNING_TIMER)
		particles.emitting = true
		await timer.timeout
		running = false
		particles.emitting = false
