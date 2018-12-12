using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneSwitcher : MonoBehaviour {

    void Update()
    {
        // loads the main scene
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            SceneManager.LoadScene("SampleScene");
        }
        
        //loads the night time version of the main scene == no directional light, darker snow
        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            SceneManager.LoadScene("SampleScene - NightVersion");
        }
	}
}
