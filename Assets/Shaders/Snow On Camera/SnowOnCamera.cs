using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class SnowOnCamera : MonoBehaviour
{
	public Texture2D SnowTexture;
    public Color SnowColour;
    private Material mat;
    //	public float SnowTextureScale = 0.1f;
    /* [Range(0, 1)] public */ float BottomThreshold = 0.45f;
	/* [Range(0, 1)] public */ float TopThreshold = 1f;

	void OnEnable()
	{
		// creates a new material that will use the Snow Shader
		mat = new Material(Shader.Find("Ice and Snow Effects/Snow On Camera"));

		// tells the camera to render depth and normals
		GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
	}

	void OnRenderImage(RenderTexture src, RenderTexture dest) 
	{
		// sets the Snow Shader's properties
		mat.SetMatrix("WorldCam", GetComponent<Camera>().cameraToWorldMatrix);
		mat.SetColor("SnowColour", SnowColour);
		mat.SetFloat("BottomThreshold", BottomThreshold);
		mat.SetFloat("TopThreshold", TopThreshold);
		mat.SetTexture("SnowTexture", SnowTexture);
	//	_material.SetFloat("_SnowTexScale", SnowTextureScale); ** not needed

		// execute the shader
		Graphics.Blit(src, dest, mat);
	}
}
