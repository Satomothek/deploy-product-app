<?php

namespace Database\Seeders;

use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $items = [
            ['name' => 'Laptop',   'price' => 8000000, 'stock' => 10],
            ['name' => 'Mouse',    'price' => 150000,  'stock' => 20],
            ['name' => 'Keyboard', 'price' => 300000,  'stock' => 15],
        ];

        foreach ($items as $item) {
            Product::firstOrCreate(['name' => $item['name']], $item);
        }
    }
}
