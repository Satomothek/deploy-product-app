<?php

namespace App\Services;

use App\Models\Product;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\Log;

class ProductService
{
    public function all(): Collection
    {
        return Product::orderBy('id')->get();
    }

    public function find(int|string $id): ?Product
    {
        return Product::find($id);
    }

    public function create(array $data): Product
    {
        $product = Product::create($data);
        Log::info('Produk dibuat', ['id' => $product->id]);

        return $product;
    }

    public function update(Product $product, array $data): Product
    {
        $product->update($data);
        Log::info('Produk diperbarui', ['id' => $product->id]);

        return $product->refresh();
    }

    public function delete(Product $product): void
    {
        $id = $product->id;
        $product->delete();
        Log::info('Produk dihapus', ['id' => $id]);
    }
}
