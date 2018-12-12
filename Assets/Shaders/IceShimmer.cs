using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IceShimmer : MonoBehaviour {

    public Material mat;
    public Material mat2;

    public float increment;
    public float counter = 0;
    public float max;
    public float min;
 //   public string parameter = "IceBrightness";
    int direction = 1;
 //   public bool doOffset = false;

    public float shine = 1;
    public float shineSpeed = 1;

	// Use this for initialization
	void Start () {
        mat = GetComponent<Renderer>().materials[0];

        if (GetComponent<Renderer>().materials.Length > 1)
            mat2 = GetComponent<Renderer>().materials[1];
	}
	
	// Update is called once per frame
	void Update () {

        counter += increment * direction;
        //mat.SetTextureOffset(Shader.PropertyToID(parameter), new Vector2(0, counter));

        if (counter > max || counter < min)
        {
            counter = Mathf.Clamp(counter, min, max);
            direction *= -1;
        }

        shine += Time.deltaTime * shineSpeed;

        //if (doOffset)
        if (mat2 != null)
            mat2.SetTextureOffset(Shader.PropertyToID("_MainTex"), new Vector2(shine / 2, shine));
        //else
        if (mat != null)
            mat.SetFloat("IceBrightness", counter);
        
        //SetTextureOffset(Shader.PropertyToID("Offset"), new Vector2(0, counter));
    }
}
