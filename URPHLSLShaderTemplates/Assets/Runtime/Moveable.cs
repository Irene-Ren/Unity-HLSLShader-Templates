using UnityEngine;

public class Moveable : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    [SerializeField]
    Transform m_transform;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(m_transform)
        {
            m_transform.position = new Vector3(Mathf.Sin(Time.time), Mathf.Cos(Time.time), 0);
        }
    }
}
