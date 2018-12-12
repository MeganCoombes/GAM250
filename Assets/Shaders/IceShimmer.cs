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
    int direction = 1;
    //   public string parameter = "IceBrightness";
    //   public bool doOffset = false;

    public float shine = 1;
    public float shineSpeed = 1;

	void Start () {
        
        // grabs the material
        mat = GetComponent<Renderer>().materials[0];

        // allows a second material to be added in the inspector
        if (GetComponent<Renderer>().materials.Length > 1)
        {
            mat2 = GetComponent<Renderer>().materials[1];
        }
	}
	
	void Update () {

        counter += increment * direction;
        //mat.SetTextureOffset(Shader.PropertyToID(parameter), new Vector2(0, counter));

        // clamps the min and max values in the counter
        if (counter > max || counter < min)
        {
            counter = Mathf.Clamp(counter, min, max);
            direction *= -1;
        }

        shine += Time.deltaTime * shineSpeed;

        //if (doOffset)

        // shifts the second material's offsets
        if (mat2 != null)
        {
            mat2.SetTextureOffset(Shader.PropertyToID("_MainTex"), new Vector2(shine / 2, shine));
        }
        //else

        if (mat != null)
        {
            mat.SetFloat("IceBrightness", counter);
        }
        
        //SetTextureOffset(Shader.PropertyToID("Offset"), new Vector2(0, counter));
    }
}
