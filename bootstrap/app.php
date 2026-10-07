<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__ . '/../routes/web.php',
        api: __DIR__ . '/../routes/api.php',
        commands: __DIR__ . '/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // Di belakang proxy hosting (HTTPS), percayai header proxy
        $middleware->trustProxies(at: '*');

        $middleware->alias([
            'request.logger' => \App\Http\Middleware\RequestLogger::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        // Semua error di /api/* selalu dibalas JSON (bukan halaman HTML)
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request, Throwable $e) => $request->is('api/*') || $request->expectsJson()
        );

        // Route/URL API yang tidak ada -> 404 JSON
        $exceptions->render(function (NotFoundHttpException $e, Request $request) {
            if ($request->is('api/*')) {
                return response()->json(['message' => 'Data tidak ditemukan'], 404);
            }
        });
    })
    ->create();
