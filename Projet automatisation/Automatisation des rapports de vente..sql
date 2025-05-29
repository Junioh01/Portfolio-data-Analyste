
/*******************************************************************************
   Filtre sur les Clients
********************************************************************************/
-- Liste des clients non américains
SELECT CustomerId, FirstName, LastName, Country
FROM customer
WHERE NOT Country="USA";

-- Liste des clients qui sont du Brésil.
SELECT*
FROM customer
WHERE Country="Brazil";


-- Liste des Factures des clients qui sont au Brésil
SELECT CustomerId, InvoiceId, FirstName, LastName, InvoiceDate, BillingCountry
FROM customer
JOIN invoice USING(CustomerId) 
GROUP BY CustomerId, FirstName, LastName, InvoiceDate, BillingCountry, InvoiceId;



-- Liste des employés qui sont  agent de vente.
SELECT*
FROM employee
WHERE Title REGEXP "Sales Support Agent";


-- Liste de tous les  pays de facturation
SELECT DISTINCT BillingCountry
FROM invoice;

--  Liste des factures par agent de vente.
SELECT 
	i.InvoiceId,
    c.CustomerId, 
    c.SupportRepId, 
    e.LastName, 
    e.FirstName 
FROM 
    customer c
JOIN 
    invoice i ON c.CustomerId = i.CustomerId
JOIN 
    employee e ON c.SupportRepId = e.EmployeeId;


-- Liste affichant le total de chaque facture, le nom du client, le pays et le nom de l'argent de vente.
SELECT 
    e.LastName, 
    c.LastName,
    e.Country,
    i.Total
FROM 
     customer c
JOIN 
    invoice i ON c.CustomerId = i.CustomerId
JOIN 
    employee e ON c.SupportRepId = e.EmployeeId;
    
    /*******************************************************************************
   Analyse par année et ligne de facture
********************************************************************************/

-- Le nombre de factures par année et montants totaux des ventes
SELECT 
    EXTRACT(YEAR FROM InvoiceDate) AS annee,
    COUNT(InvoiceId) AS nombre_facture,   
    SUM(Total) AS montant_totaux          
FROM 
    invoice
GROUP BY 
    annee; 
    
-- Nombre d'articles pour chaque facture
SELECT
      InvoiceId,
      COUNT(InvoiceId) AS nombre_article
FROM 
    invoiceline
GROUP BY 
        InvoiceId;

-- Liste des noms de morceaux pour chaque ligne de facture
SELECT 
      InvoiceLineId,
	  TrackId,
      Name
FROM invoiceline
LEFT JOIN track USING(TrackId); 

-- Liste contenant le nom du morceau acheté et le nom de l'artiste pour chaque ligne de facture.
SELECT 
      t.Name AS Atiste_Name,
      a.Name AS Track_Name
FROM 
	invoiceline
LEFT JOIN track t USING(TrackId)
JOIN album AS al USING(AlbumId)
JOIN artist a USING(ArtistId);

-- Liste Donnant les information sur les morceaux en incluant le nom de l'album, le type de média et le genre
 SELECT 
	  t.Name AS Track_Name,
      t.Composer, 
	  t.Milliseconds, 
      t.Bytes ,
	  t.UnitPrice,
      a.Title AS Album_Name,
      g.Name AS Genre_Name,
      m.Name AS Type_Media_Name
FROM  album  a
JOIN track t  USING(AlbumId) 
JOIN mediatype m USING(MediaTypeId)
JOIN genre g USING(GenreId);  

 /*******************************************************************************
   Analyse des ventes
********************************************************************************/  

--  Ventes totales réalisées par chaque agent de vente.
SELECT 
    e.LastName, 
    e.FirstName,
    SUM(Total) AS Vente_Totale
FROM 
    customer c
JOIN 
    invoice i ON c.CustomerId = i.CustomerId
JOIN 
    employee e ON c.SupportRepId = e.EmployeeId
GROUP BY
    e.FirstName,
    e.LastName;
     
     
-- Agent de vente ayant réalisé le plus de ventes en 2021
SELECT 
    EXTRACT(YEAR FROM InvoiceDate) AS annee,
    e.LastName, 
    e.FirstName,
    SUM(i.Total) AS Vente_Totale
FROM 
    customer c
JOIN 
    invoice i ON c.CustomerId = i.CustomerId
JOIN 
    employee e ON c.SupportRepId = e.EmployeeId
WHERE
    EXTRACT(YEAR FROM InvoiceDate) = 2021
GROUP BY
    e.LastName,
    e.FirstName,
    EXTRACT(YEAR FROM InvoiceDate)
ORDER BY
    Vente_Totale DESC
LIMIT 1;

/*******************************************************************************
   Analyse des Clients et des pays
********************************************************************************/  

-- Nombre de clients attribués à chaque agente.
SELECT 
    e.LastName, 
    e.FirstName,
    COUNT(c.CustomerId) AS Nombre_Clients
FROM 
    customer c
JOIN 
    invoice i ON c.CustomerId = i.CustomerId
JOIN 
    employee e ON c.SupportRepId = e.EmployeeId
GROUP BY
    e.FirstName,
    e.LastName;
    
-- Ventes totales par pays par ordre décroissant.
SELECT 
      BillingCountry,
      SUM(Total)
FROM 
     invoice
GROUP BY 
       BillingCountry
ORDER BY SUM(Total) DESC;

/*******************************************************************************
   Analyse des Morceaux et des Artistes
********************************************************************************/  

-- Le morceau le plus acheté en 2024.
SELECT
    EXTRACT(YEAR FROM InvoiceDate) AS annee,
      TrackId,
      Name,
      SUM(Total)  As Montant_vente 
FROM invoice 
JOIN invoiceline USING(InvoiceId)
JOIN track  Using(TrackId)
WHERE
    EXTRACT(YEAR FROM InvoiceDate) = 2024
GROUP BY 
    EXTRACT(YEAR FROM InvoiceDate),
       TrackId,
       Name
ORDER BY
    Montant_vente  DESC
LIMIT 1;

-- TOP 5 des morceaux les plus achetés en tout.
SELECT
      TrackId,
      Name,
      SUM(Total)  As Montant_vente 
FROM invoice 
JOIN invoiceline USING(InvoiceId)
JOIN track  Using(TrackId)
GROUP BY 
       TrackId,
       Name
ORDER BY
    Montant_vente  DESC
LIMIT 5;

-- Top 3 des artistes les plus vendus
SELECT 
      a.Name AS Atiste_Name,
      SUM(i.Total) AS Vente_total
FROM 
	invoiceline 
JOIN track t USING(TrackId)
JOIN album AS al USING(AlbumId)
JOIN artist a USING(ArtistId)
JOIN invoice i USING(InvoiceId)
GROUP BY 
        a.Name 
ORDER BY
       SUM(i.Total) DESC
LIMIT 3;

-- Type de média le plus acheté
SELECT 
      m.Name AS Media_Name,
      SUM(i.Total) AS Vente_total
FROM 
	invoiceline 
JOIN track t USING(TrackId)
JOIN mediatype m USING(MediaTypeId)
JOIN invoice i USING(InvoiceId)
GROUP BY 
        m.Name 
ORDER BY
       SUM(i.Total) DESC
LIMIT 1;

     