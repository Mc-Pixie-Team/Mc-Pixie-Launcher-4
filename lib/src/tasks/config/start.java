package cpw.mods.bootstraplauncher;

import java.util.AbstractCollection;
import java.util.Objects;
import java.io.IOException;
import java.lang.module.Configuration;
import java.util.Iterator;
import java.util.Map;
import java.util.ServiceLoader;
import java.util.function.Consumer;
import cpw.mods.cl.ModuleClassLoader;
import java.lang.module.ModuleFinder;
import cpw.mods.cl.JarModuleFinder;
import java.util.function.Function;
import java.util.Arrays;
import java.util.function.BiPredicate;
import java.util.Collection;
import java.util.Set;
import java.util.Comparator;
import java.nio.file.Files;
import java.nio.file.LinkOption;
import java.nio.file.Paths;
import java.util.List;
import java.util.LinkedHashMap;
import java.nio.file.Path;
import java.util.HashMap;
import cpw.mods.jarhandling.SecureJar;
import java.util.ArrayList;
import java.util.HashSet;
import java.io.File;

public class BootstrapLauncher
{
    private static final boolean DEBUG;
    
    public static void main(final String... args) {
        final List<String> legacyClasspath = loadLegacyClassPath();
        System.setProperty("legacyClassPath", String.join(File.pathSeparator, legacyClasspath));
        final String ignoreList = System.getProperty("ignoreList", "asm,securejarhandler");
        final String[] ignores = ignoreList.split(",");
        final HashSet<String> previousPackages = new HashSet<String>();
        final ArrayList<SecureJar> jars = new ArrayList<SecureJar>();
        final HashMap<Path, String> pathLookup = new HashMap<Path, String>();
        final Map<String, String> filenameMap = getMergeFilenameMap();
        final LinkedHashMap<String, List<Path>> mergeMap = new LinkedHashMap<String, List<Path>>();
        final ArrayList<String> order = new ArrayList<String>();
    Label_0090:
        for (final String legacy : legacyClasspath) {
            final Path path2 = Paths.get(legacy, new String[0]);
            final String filename = path2.getFileName().toString();
            final String[] array = ignores;
            final int length = array.length;
            int i = 0;
            while (i < length) {
                final String filter = array[i];
                if (filename.startsWith(filter)) {
                    if (BootstrapLauncher.DEBUG) {
                        System.out.println(invokedynamic(makeConcatWithConstants:(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;, legacy, filter));
                        continue Label_0090;
                    }
                    continue Label_0090;
                }
                else {
                    ++i;
                }
            }
            if (BootstrapLauncher.DEBUG) {
                System.out.println(invokedynamic(makeConcatWithConstants:(Ljava/lang/String;)Ljava/lang/String;, legacy));
            }
            if (Files.notExists(path2, new LinkOption[0])) {
                continue;
            }
            final SecureJar jar = SecureJar.from(new Path[] { path2 });
            if ("".equals(jar.name())) {
                continue;
            }
            final String jarname = pathLookup.computeIfAbsent(path2, k -> filenameMap.getOrDefault(filename, jar.name()));
            order.add(jarname);
            mergeMap.computeIfAbsent(jarname, k -> new ArrayList()).add(path2);
        }
        final String name;
        final List<Path> paths;
        Path[] pathsArray;
        final Collection<? extends E> coll;
        SecureJar jar2;
        Set<String> packages;
        final ArrayList<SecureJar> list;
        mergeMap.entrySet().stream().sorted(Comparator.comparingInt(e -> order.indexOf(e.getKey()))).forEach(e -> {
            name = e.getKey();
            paths = (List<Path>)e.getValue();
            if (paths.size() == 1 && Files.notExists(paths.get(0), new LinkOption[0])) {
                return;
            }
            else {
                pathsArray = paths.toArray(Path[]::new);
                jar2 = SecureJar.from((BiPredicate)new BootstrapLauncher.PackageTracker((Set)Set.copyOf((Collection<?>)coll), pathsArray), pathsArray);
                packages = (Set<String>)jar2.getPackages();
                if (BootstrapLauncher.DEBUG) {
                    System.out.println(invokedynamic(makeConcatWithConstants:(Ljava/lang/String;)Ljava/lang/String;, name));
                    paths.forEach(path -> System.out.println(invokedynamic(makeConcatWithConstants:(Ljava/nio/file/Path;)Ljava/lang/String;, path)));
                    System.out.println(invokedynamic(makeConcatWithConstants:(Ljava/lang/String;)Ljava/lang/String;, name));
                    packages.forEach(p -> System.out.println(invokedynamic(makeConcatWithConstants:(Ljava/lang/String;)Ljava/lang/String;, p)));
                }
                ((AbstractCollection<Object>)coll).addAll(packages);
                list.add(jar2);
                return;
            }
        });
        final SecureJar[] secureJarsArray = jars.toArray(SecureJar[]::new);
        final List<String> allTargets = (List<String>)Arrays.stream(secureJarsArray).map((Function<? super SecureJar, ?>)SecureJar::name).toList();
        final JarModuleFinder jarModuleFinder = JarModuleFinder.of(secureJarsArray);
        final Configuration bootModuleConfiguration = ModuleLayer.boot().configuration();
        final Configuration bootstrapConfiguration = bootModuleConfiguration.resolveAndBind((ModuleFinder)jarModuleFinder, ModuleFinder.ofSystem(), allTargets);
        final ModuleClassLoader moduleClassLoader = new ModuleClassLoader("MC-BOOTSTRAP", bootstrapConfiguration, (List)List.of(ModuleLayer.boot()));
        final ModuleLayer.Controller layer = ModuleLayer.defineModules(bootstrapConfiguration, List.of(ModuleLayer.boot()), m -> moduleClassLoader);
        Thread.currentThread().setContextClassLoader((ClassLoader)moduleClassLoader);
        final ServiceLoader<Consumer> loader = (ServiceLoader<Consumer>)ServiceLoader.load(layer.layer(), Consumer.class);
        loader.stream().findFirst().orElseThrow().get().accept(args);
    }
    
    private static Map<String, String> getMergeFilenameMap() {
        final String mergeModules = System.getProperty("mergeModules");
        if (mergeModules == null) {
            return Map.of();
        }
        final Map<String, String> filenameMap = new HashMap<String, String>();
        int i = 0;
        for (final String merge : mergeModules.split(";")) {
            final String[] split2;
            final String[] targets = split2 = merge.split(",");
            for (final String target : split2) {
                filenameMap.put(target, String.valueOf(i));
            }
            ++i;
        }
        return filenameMap;
    }
    
    private static List<String> loadLegacyClassPath() {
        final String legacyCpPath = System.getProperty("legacyClassPath.file");
        if (legacyCpPath != null) {
            final Path legacyCPFileCandidatePath = Paths.get(legacyCpPath, new String[0]);
            if (Files.exists(legacyCPFileCandidatePath, new LinkOption[0]) && Files.isRegularFile(legacyCPFileCandidatePath, new LinkOption[0])) {
                try {
                    return Files.readAllLines(legacyCPFileCandidatePath);
                }
                catch (IOException e) {
                    throw new IllegalStateException(invokedynamic(makeConcatWithConstants:(Ljava/lang/String;)Ljava/lang/String;, legacyCpPath), (Throwable)e);
                }
            }
        }
        final String legacyClasspath = System.getProperty("legacyClassPath", System.getProperty("java.class.path"));
        Objects.requireNonNull(legacyClasspath, "Missing legacyClassPath, cannot bootstrap");
        if (legacyClasspath.length() == 0) {
            return List.of();
        }
        return Arrays.asList(legacyClasspath.split(File.pathSeparator));
    }
    
    static {
        DEBUG = System.getProperties().containsKey("bsl.debug");
    }
}