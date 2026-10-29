@tool
extends EditorPlugin

var export_plugin: AndroidExportPlugin

func _enter_tree() -> void:
	export_plugin = AndroidExportPlugin.new()
	add_export_plugin(export_plugin)

func _exit_tree() -> void:
	remove_export_plugin(export_plugin)
	export_plugin = null

class AndroidExportPlugin extends EditorExportPlugin:
	var _plugin_name := "RiftRushAds"

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_android_libraries(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
		return PackedStringArray(["riftrush_ads/bin/RiftRushAds.aar"])

	func _get_android_dependencies(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
		return PackedStringArray([
			"com.google.android.gms:play-services-ads:25.5.0",
			"com.google.android.ump:user-messaging-platform:4.0.0",
		])

	func _get_android_dependencies_maven_repos(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
		return PackedStringArray([
			"https://dl.google.com/dl/android/maven2",
			"https://repo1.maven.org/maven2",
		])

	func _get_android_manifest_application_element_contents(_platform: EditorExportPlatform, _debug: bool) -> String:
		var app_id := _app_id()
		if app_id == "" or app_id.contains("\"") or app_id.contains("<"):
			push_error("RiftRushAds: ads_config.gd APP_ID is missing or unsafe")
			return ""
		return "<meta-data android:name=\"com.google.android.gms.ads.APPLICATION_ID\" android:value=\"%s\"/>" % app_id

	func _get_name() -> String:
		return _plugin_name

	func _app_id() -> String:
		var script: Script = load("res://ads_config.gd")
		if script == null:
			return ""
		var values: Dictionary = script.get_script_constant_map()
		return str(values.get("APP_ID", ""))
