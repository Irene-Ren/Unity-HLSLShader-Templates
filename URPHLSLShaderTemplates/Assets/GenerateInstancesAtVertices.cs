using System;
using UnityEngine;
using UnityEditor;


public class GenerateInstancesAtVertices : MonoBehaviour
{
    public MeshFilter sourceMeshFilter; // 提供要读取顶点的网格
    public GameObject prefabToInstantiate; // 要在每个顶点上生成的预制件
    
    private GameObject[] generatedInstances; // 用于存储生成的实例

    #if UNITY_EDITOR
    [ContextMenu("Generate Instances at Vertices")]
    void GenerateInstances()
    {
        if (sourceMeshFilter == null || prefabToInstantiate == null)
        {
            Debug.LogError("Source MeshFilter or Prefab is not assigned!");
            return;
        }

        Mesh mesh = sourceMeshFilter.sharedMesh;
        Vector3[] vertices = mesh.vertices;

        // 初始化存储数组
        generatedInstances = new GameObject[vertices.Length];
        
        for (int i = 0; i < vertices.Length; i++)
        {
            // 将顶点坐标从局部空间转换为世界空间
            Vector3 worldPosition = sourceMeshFilter.transform.TransformPoint(vertices[i]);

            // 在顶点位置生成预制件的实例
            GameObject instance = PrefabUtility.InstantiatePrefab(prefabToInstantiate) as GameObject;
            instance.transform.position = worldPosition;
            instance.transform.parent = gameObject.transform; 
            
            // 存储生成的实例
            generatedInstances[i] = instance;
        }

        Debug.Log("Instances generated at all vertices.");
    }
    #endif

    private void OnDisable()
    {
        // 清理生成的实例
        if (generatedInstances != null)
        {
            foreach (var instance in generatedInstances)
            {
                if (instance != null)
                {
                    DestroyImmediate(instance); // 立即销毁实例
                }
            }
            generatedInstances = null; // 清空数组
        }

        Debug.Log("Cleaned up generated instances.");
    }
}
