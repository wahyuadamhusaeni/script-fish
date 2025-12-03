#!/usr/bin/env node

/**
 * Simple Lua Module Bundler
 *
 * This script bundles multiple Lua modules into a single file
 * that can be executed by Roblox executors.
 *
 * Usage:
 *   node tools/bundler.js
 *
 * Or with npm:
 *   npm run build
 */

const fs = require('fs');
const path = require('path');

// Configuration
const CONFIG = {
    entryPoint: 'src/main',
    outputPath: 'build/script.lua',
    sourceDir: 'src',
    banner: `
--[[
    ╔═══════════════════════════════════════════════════╗
    ║          Roblox FishIt Script - Bundled          ║
    ║                                                   ║
    ║  Build Date: {BUILD_DATE}                        ║
    ║  Version: {VERSION}                              ║
    ║                                                   ║
    ║  ⚠️  FOR EDUCATIONAL PURPOSES ONLY               ║
    ║                                                   ║
    ╚═══════════════════════════════════════════════════╝
]]
`.trim()
};

class LuaBundler {
    constructor() {
        this.modules = new Map();
        this.processed = new Set();
        this.stats = {
            totalFiles: 0,
            totalLines: 0,
            totalSize: 0
        };
    }

    /**
     * Read file content
     */
    readFile(filePath) {
        try {
            return fs.readFileSync(filePath, 'utf8');
        } catch (error) {
            throw new Error(`Could not read file: ${filePath}\n${error.message}`);
        }
    }

    /**
     * Write file content
     */
    writeFile(filePath, content) {
        try {
            // Ensure directory exists
            const dir = path.dirname(filePath);
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir, { recursive: true });
            }

            fs.writeFileSync(filePath, content, 'utf8');
            return true;
        } catch (error) {
            throw new Error(`Could not write to file: ${filePath}\n${error.message}`);
        }
    }

    /**
     * Extract require() calls from Lua code
     */
    extractRequires(content) {
        const requires = [];

        // Match: require("path") or require('path')
        const regex = /require\s*\(\s*["']([^"']+)["']\s*\)/g;
        let match;

        while ((match = regex.exec(content)) !== null) {
            requires.push(match[1]);
        }

        return requires;
    }

    /**
     * Resolve module path
     */
    resolvePath(modulePath) {
        // Remove "src/" prefix if present
        modulePath = modulePath.replace(/^src\//, '');

        // Add .lua extension if not present
        if (!modulePath.endsWith('.lua')) {
            modulePath += '.lua';
        }

        return path.join(CONFIG.sourceDir, modulePath);
    }

    /**
     * Process a single file and its dependencies
     */
    processFile(modulePath) {
        // Normalize path
        const normalizedPath = modulePath.replace(/^src\//, '').replace(/\.lua$/, '');

        // Skip if already processed
        if (this.processed.has(normalizedPath)) {
            return;
        }

        this.processed.add(normalizedPath);

        console.log(`📦 Processing: ${normalizedPath}`);

        // Read file
        const filePath = this.resolvePath(modulePath);
        const content = this.readFile(filePath);

        // Extract dependencies
        const requires = this.extractRequires(content);

        // Process dependencies first (depth-first)
        for (const reqPath of requires) {
            this.processFile(reqPath);
        }

        // Store module
        this.modules.set(normalizedPath, content);

        // Update stats
        this.stats.totalFiles++;
        this.stats.totalLines += content.split('\n').length;
        this.stats.totalSize += Buffer.byteLength(content, 'utf8');
    }

    /**
     * Generate the bundled output
     */
    generateBundle() {
        const buildDate = new Date().toISOString().replace('T', ' ').substring(0, 19);
        const version = '2.0.0'; // TODO: Read from version.lua

        // Replace placeholders in banner
        const banner = CONFIG.banner
            .replace('{BUILD_DATE}', buildDate)
            .replace('{VERSION}', version);

        let output = banner + '\n\n';

        // Add module system
        output += `
-- ============================================
-- MODULE SYSTEM
-- ============================================

local Modules = {}
local LoadedModules = {}

-- Custom require function
local function require(moduleName)
    -- Normalize module name
    moduleName = moduleName:gsub("^src/", "")
    moduleName = moduleName:gsub("%.lua$", "")

    -- Return cached module if already loaded
    if LoadedModules[moduleName] then
        return LoadedModules[moduleName]
    end

    -- Get module function
    local moduleFunc = Modules[moduleName]
    if not moduleFunc then
        error("Module not found: " .. moduleName)
    end

    -- Execute module and cache result
    local result = moduleFunc()
    LoadedModules[moduleName] = result
    return result
end

-- ============================================
-- MODULES
-- ============================================

`;

        // Add all modules
        for (const [moduleName, content] of this.modules) {
            output += `-- Module: ${moduleName}\n`;
            output += `Modules["${moduleName}"] = function()\n`;

            // Indent module content
            const indentedContent = content
                .split('\n')
                .map(line => line ? '    ' + line : '')
                .join('\n');

            output += indentedContent;
            output += `\nend\n\n`;
        }

        // Add entry point execution
        output += `
-- ============================================
-- ENTRY POINT
-- ============================================

-- Execute main module
require("main")
`;

        return output;
    }

    /**
     * Bundle all modules
     */
    bundle() {
        console.log('🚀 Starting bundler...\n');

        try {
            // Process from entry point
            this.processFile(CONFIG.entryPoint);

            console.log('\n✅ All modules processed successfully!');
            console.log('\n📊 Statistics:');
            console.log(`   Files: ${this.stats.totalFiles}`);
            console.log(`   Lines: ${this.stats.totalLines}`);
            console.log(`   Size: ${(this.stats.totalSize / 1024).toFixed(2)} KB`);

            // Generate bundle
            console.log('\n🔧 Generating bundle...');
            const bundledCode = this.generateBundle();

            // Write output
            console.log(`📝 Writing to ${CONFIG.outputPath}...`);
            this.writeFile(CONFIG.outputPath, bundledCode);

            // Final stats
            const outputSize = Buffer.byteLength(bundledCode, 'utf8');
            console.log(`✅ Bundle created successfully!`);
            console.log(`   Output size: ${(outputSize / 1024).toFixed(2)} KB`);
            console.log(`   Compression ratio: ${((1 - outputSize / this.stats.totalSize) * 100).toFixed(2)}%`);

            return true;
        } catch (error) {
            console.error('\n❌ Error during bundling:');
            console.error(error.message);
            process.exit(1);
        }
    }
}

// ============================================
// MAIN EXECUTION
// ============================================

if (require.main === module) {
    const bundler = new LuaBundler();
    bundler.bundle();
}

module.exports = LuaBundler;
