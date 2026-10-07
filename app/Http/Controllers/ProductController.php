<?php

namespace App\Http\Controllers;

use App\Services\ProductService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function __construct(private ProductService $productService)
    {
    }

    // GET /api/products
    public function index(): JsonResponse
    {
        return response()->json([
            'message' => 'Data berhasil diambil',
            'data'    => $this->productService->all(),
        ]);
    }

    // GET /api/products/{id}
    public function show(string $id): JsonResponse
    {
        $product = $this->productService->find($id);

        if (! $product) {
            return $this->notFound();
        }

        return response()->json([
            'message' => 'Data berhasil diambil',
            'data'    => $product,
        ]);
    }

    // POST /api/products
    public function store(Request $request): JsonResponse
    {
        // Gagal validasi -> Laravel otomatis kirim 422 + JSON error
        $validated = $request->validate([
            'name'  => 'required|string|max:100',
            'price' => 'required|integer|min:0',
            'stock' => 'sometimes|integer|min:0',
        ]);

        $product = $this->productService->create($validated);

        return response()->json([
            'message' => 'Produk berhasil dibuat',
            'data'    => $product,
        ], 201);
    }

    // PUT/PATCH /api/products/{id}
    public function update(Request $request, string $id): JsonResponse
    {
        $product = $this->productService->find($id);

        if (! $product) {
            return $this->notFound();
        }

        $validated = $request->validate([
            'name'  => 'sometimes|required|string|max:100',
            'price' => 'sometimes|required|integer|min:0',
            'stock' => 'sometimes|integer|min:0',
        ]);

        $product = $this->productService->update($product, $validated);

        return response()->json([
            'message' => 'Produk berhasil diperbarui',
            'data'    => $product,
        ]);
    }

    // DELETE /api/products/{id}
    public function destroy(string $id): JsonResponse
    {
        $product = $this->productService->find($id);

        if (! $product) {
            return $this->notFound();
        }

        $this->productService->delete($product);

        return response()->json(['message' => 'Produk berhasil dihapus']);
    }

    private function notFound(): JsonResponse
    {
        return response()->json(['message' => 'Data tidak ditemukan'], 404);
    }
}
