<?php

use App\Http\Controllers\ProductController;
use Illuminate\Support\Facades\Route;

Route::middleware('request.logger')->group(function () {
    // GET/POST /products, GET/PUT/PATCH/DELETE /products/{id}
    Route::apiResource('products', ProductController::class);
});
